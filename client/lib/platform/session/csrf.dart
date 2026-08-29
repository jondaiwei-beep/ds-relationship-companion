import 'csrf_io.dart' if (dart.library.js_interop) 'csrf_web.dart';

/// Reads the CSRF token the server paired with the Web refresh cookie.
///
/// The server sets two cookies on Web: `__Host-refresh`, httpOnly so script
/// cannot read it, and `__Host-refresh-csrf`, deliberately readable. A
/// refresh must present the second in an `X-Refresh-CSRF` header, which
/// proves the request came from this origin's code rather than from a
/// cross-site request that merely carried the cookie along. The server
/// rejects a Web refresh without it.
///
/// Returns null on Android, where the refresh token travels in the request
/// body and there is no ambient credential to defend.
///
/// **This only works when the Web app and the API share an origin.** The
/// `__Host-` prefix forbids a `Domain` attribute, so the cookie is bound to
/// the API host exactly; script served from a sibling subdomain cannot read
/// it and this returns null there, making every Web refresh fail with 401.
/// Deploying the Web app behind the same origin as the API — a reverse proxy
/// on one host — resolves it. Returning the token in the response body would
/// too, but that is a server change. Tracked in `progress/STATE.md`.
abstract interface class CsrfTokens {
  String? read();

  factory CsrfTokens() = CsrfTokensImpl;
}

/// The cookie the server writes it to, and the header it expects back.
const csrfCookieName = '__Host-refresh-csrf';
const csrfHeaderName = 'X-Refresh-CSRF';
