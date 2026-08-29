import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

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
  }

  final Dio _dio;
  static final _rng = Random.secure();

  /// Access token lives in memory only — never on disk (Notion 04 §2).
  ///
  /// Written by `SessionController` and nothing else: two writers would mean
  /// two answers to "who is signed in".
  String? _accessToken;
  set accessToken(String? t) => _accessToken = t;

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
    final r = await _dio.get<Map<String, dynamic>>(path, options: _authed);
    return r.data ?? const {};
  }

  /// GET an endpoint that returns a JSON array rather than an object.
  Future<List<dynamic>> getList(String path) async {
    final r = await _dio.get<List<dynamic>>(path, options: _authed);
    return r.data ?? const [];
  }

  /// POST a command. [idempotencyKey] must be stable across retries of the
  /// SAME user action, and different for a new one.
  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    String? idempotencyKey,
    bool authenticated = true,
  }) async {
    final token = _accessToken;
    final options = Options(
      headers: {
        if (authenticated && token != null) 'Authorization': 'Bearer $token',
        'Idempotency-Key': ?idempotencyKey,
      },
    );
    final r = await _dio.post<Map<String, dynamic>>(path, data: body, options: options);
    return r.data ?? const {};
  }
}
