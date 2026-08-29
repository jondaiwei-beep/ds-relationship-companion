import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'credentials_io.dart'
    if (dart.library.js_interop) 'credentials_web.dart';

/// HTTP client for the dsapp backend.
///
/// Every mutation carries an `Idempotency-Key` so a retry — a flaky mobile
/// network, a double tap — can never produce a second business action
/// (Notion 03 §6).
class ApiClient {
  ApiClient({required String baseUrl, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers['Content-Type'] = 'application/json';

    // Browsers omit cookies from cross-origin requests unless asked, and the
    // Web app and the API are separate hosts. Without this the refresh cookie
    // is never set, never sent and never cleared: sign-in appears to work,
    // then every reload signs the person back out.
    //
    // "Same-site" for SameSite=Strict and "same-origin" for fetch credentials
    // are different rules; sibling subdomains satisfy the first, not the
    // second.
    configureCredentials(_dio);
  }

  final Dio _dio;

  /// Called when the server says this token is dead.
  ///
  /// On a protected endpoint a 401 has exactly one meaning: the security
  /// filter rejected the bearer token. Authorization failures answer 404 by
  /// design — revealing "this exists but is not yours" would leak
  /// relationship structure — so there is no "you may not read *this*" case
  /// to confuse it with.
  ///
  /// Wired to the session by `SessionController`, so one rejected request
  /// ends the session everywhere instead of each screen discovering it
  /// separately.
  void Function()? onAuthenticationLost;
  static final _rng = Random.secure();

  /// Access token lives in memory only — never on disk (Notion 04 §2).
  ///
  /// Written by `SessionController` and nothing else: two writers would mean
  /// two answers to "who is signed in".
  String? _accessToken;
  set accessToken(String? t) => _accessToken = t;

  /// Installs the 401 handler. Called once, by the session.
  void interceptAuthenticationLoss(void Function() onLost) {
    onAuthenticationLost = onLost;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final status = error.response?.statusCode;
          // Only for requests that carried a token. A 401 from `/sign-in` is
          // a wrong password, not a lost session, and ending the session
          // there would clear the very thing the person is trying to create.
          final wasAuthenticated =
              error.requestOptions.headers.containsKey('Authorization');
          if (status == 401 && wasAuthenticated) onAuthenticationLost?.call();
          handler.next(error);
        },
      ),
    );
  }

  /// Fires the authentication-lost path without a real 401, for tests.
  @visibleForTesting
  void debugSimulateAuthenticationLoss() => onAuthenticationLost?.call();

  /// Whether requests are currently authorized, for tests.
  ///
  /// Deliberately not a plain getter: production code that needs to know
  /// whether someone is signed in must ask the session, which is the single
  /// source of truth, rather than inferring it from transport state.
  @visibleForTesting
  String? get debugAccessToken => _accessToken;

  Options get _authed => Options(headers: _authHeaders());

  Map<String, String> _authHeaders() {
    final token = _accessToken;
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  static String newIdempotencyKey() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    return b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<Map<String, dynamic>> get(String path) async {
    _requireSession(path);
    final r = await _dio.get<Map<String, dynamic>>(path, options: _authed);
    return r.data ?? const {};
  }

  /// GET an endpoint that returns a JSON array rather than an object.
  Future<List<dynamic>> getList(String path) async {
    _requireSession(path);
    final r = await _dio.get<List<dynamic>>(path, options: _authed);
    return r.data ?? const [];
  }

  /// Refuse to send an authenticated request with no session.
  ///
  /// Without this the client quietly drops the `Authorization` header and
  /// sends anyway. The server rejects it, so nothing leaks — but the request
  /// still went out, carrying a path that names a Dynamic, and the failure
  /// surfaces as a generic error rather than as authorization loss.
  ///
  /// The router keeps the one built screen from reaching here. That is a
  /// widget-level guard, and there are thirty-four screens to come plus
  /// providers, lifecycle callbacks and retries that never touch a widget.
  /// The transport is the layer that can actually hold this line.
  void _requireSession(String path) {
    if (_accessToken != null) return;
    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.cancel,
      error: 'No session: refusing to send an authenticated request.',
      response: Response<void>(
        requestOptions: RequestOptions(path: path),
        statusCode: 401,
      ),
    );
  }

  /// POST a command. [idempotencyKey] must be stable across retries of the
  /// SAME user action, and different for a new one.
  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    String? idempotencyKey,
    bool authenticated = true,
    Map<String, String> headers = const {},
  }) async {
    if (authenticated) _requireSession(path);
    final token = _accessToken;
    final options = Options(
      headers: {
        if (authenticated && token != null) 'Authorization': 'Bearer $token',
        'Idempotency-Key': ?idempotencyKey,
        ...headers,
      },
    );
    final r = await _dio.post<Map<String, dynamic>>(path, data: body, options: options);
    return r.data ?? const {};
  }
}
