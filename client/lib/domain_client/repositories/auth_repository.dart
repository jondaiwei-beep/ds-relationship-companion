import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../api_client.dart';

/// One passwordless sign-in attempt.
///
/// PKCE-style: the verifier never leaves the device; only its SHA-256
/// challenge is sent when requesting the link. A forwarded or intercepted
/// magic link therefore cannot authenticate in a browser that did not start
/// the flow (Notion 04 §2).
class AuthFlow {
  AuthFlow({required this.flowId, required this.verifier, this.returnTo});

  final String flowId;
  final String verifier;
  final String? returnTo;

  String get challenge =>
      base64Url.encode(sha256.convert(utf8.encode(verifier)).bytes).replaceAll('=', '');

  Map<String, dynamic> toJson() =>
      {'flowId': flowId, 'verifier': verifier, 'returnTo': returnTo};

  static AuthFlow fromJson(Map<String, dynamic> j) => AuthFlow(
        flowId: j['flowId'] as String,
        verifier: j['verifier'] as String,
        returnTo: j['returnTo'] as String?,
      );

  static final _rng = Random.secure();

  static String _random(int bytes) {
    final b = List<int>.generate(bytes, (_) => _rng.nextInt(256));
    return base64Url.encode(b).replaceAll('=', '');
  }

  static String _uuid() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}'
        '-${h.substring(16, 20)}-${h.substring(20)}';
  }

  static AuthFlow start({String? returnTo}) =>
      AuthFlow(flowId: _uuid(), verifier: _random(32), returnTo: returnTo);
}

class AuthResult {
  AuthResult({
    required this.accessToken,
    required this.accessTokenExpiresIn,
    this.refreshToken,
    this.continuationInviteState,
  });

  final String accessToken;

  /// How long the access token stays valid. The session refreshes ahead of
  /// this rather than waiting for a 401, so a person mid-sentence is not
  /// interrupted by an expiry the client could see coming.
  final Duration accessTokenExpiresIn;

  /// Android only. Web receives an httpOnly `__Host-refresh` cookie instead,
  /// which JavaScript cannot read and therefore this client never sees.
  final String? refreshToken;

  /// Where the user was heading before authenticating, resolved server-side.
  final String? continuationInviteState;

  static AuthResult fromJson(Map<String, dynamic> r) => AuthResult(
        accessToken: r['accessToken'] as String,
        accessTokenExpiresIn:
            Duration(seconds: (r['accessTokenExpiresInSeconds'] as num).toInt()),
        refreshToken: r['refreshToken'] as String?,
        continuationInviteState:
            (r['continuation'] as Map<String, dynamic>?)?['state'] as String?,
      );
}

/// Web gets a refresh cookie; Android gets the token in the body.
String get _clientType => kIsWeb ? 'WEB' : 'ANDROID';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  /// Requests the emailed sign-in link. [inviteToken] lets the server carry the
  /// invite continuation, so the link returns the user to the right context.
  Future<void> requestMagicLink({
    required String email,
    required AuthFlow flow,
    String? inviteToken,
  }) =>
      _api.post(
        '/v1/auth/magic-links',
        authenticated: false,
        body: {
          'email': email,
          'flowId': flow.flowId,
          'codeChallenge': flow.challenge,
          'inviteToken': inviteToken,
        },
      );

  /// Staging only: the link this process just issued for [email].
  ///
  /// Staging has no email sender. The endpoint behind this exists only under
  /// the server's `staging` profile and has no production counterpart.
  Future<String> stagingLastLink(String email) async {
    final r = await _api.get(
      '/v1/staging/last-magic-link?email=${Uri.encodeQueryComponent(email)}',
    );
    final url = r['url'] as String?;
    if (url == null) throw StateError('staging issued no link for $email');
    return url;
  }

  /// Create an account with an email and a password.
  ///
  /// The ordinary door. A magic link means leaving the app, finding a mail
  /// client and coming back — on a phone, in a spare minute, that is where
  /// most people stop.
  Future<AuthResult> register({
    required String email,
    required String password,
    required bool ageConfirmed,
  }) async {
    final r = await _api.post(
      '/v1/auth/register',
      authenticated: false,
      body: {
        'email': email,
        'password': password,
        'clientType': _clientType,
        'ageConfirmed': ageConfirmed,
      },
    );
    return AuthResult.fromJson(r);
  }

  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final r = await _api.post(
      '/v1/auth/sign-in',
      authenticated: false,
      body: {
        'email': email,
        'password': password,
        'clientType': _clientType,
      },
    );
    return AuthResult.fromJson(r);
  }

  /// End this session.
  ///
  /// A shared or borrowed device is the ordinary case for a private app, so
  /// signing out is a safety control, not a settings nicety (Notion 04 §11).
  /// The server clears the refresh cookie; the access token only ever lived
  /// in memory.
  Future<void> logout() => _api.post('/v1/auth/logout');

  Future<AuthResult> consume({
    required String token,
    required AuthFlow flow,
    required String clientType,
  }) async {
    final r = await _api.post(
      '/v1/auth/magic-links/consume',
      authenticated: false,
      body: {
        'token': token,
        'flowId': flow.flowId,
        'codeVerifier': flow.verifier,
        'clientType': clientType,
      },
    );
    return AuthResult.fromJson(r);
  }

  /// Exchange the refresh credential for a new access token.
  ///
  /// Android sends the stored refresh token; Web sends nothing and the
  /// browser attaches the httpOnly cookie. A rejection here is not an error
  /// to retry — it means the session is over.
  Future<AuthResult> refresh({String? refreshToken}) async {
    final r = await _api.post(
      '/v1/auth/refresh',
      authenticated: false,
      body: refreshToken == null ? null : {'refreshToken': refreshToken},
    );
    return AuthResult.fromJson(r);
  }
}
