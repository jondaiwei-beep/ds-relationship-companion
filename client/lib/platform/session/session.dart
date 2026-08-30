import 'dart:convert';

/// Who is signed in, and whether the app may show relationship content.
///
/// Three states, not two. "Not signed in" and "was signed in, and the session
/// ended" are the same to an authenticator and completely different to a
/// person: the first is a door, the second is an interruption in the middle
/// of something private, possibly on a borrowed device.
sealed class Session {
  const Session();

  /// True only when the server has granted this process an access token.
  /// Guards read this; nothing else should pattern-match on the type to
  /// decide whether protected content may render.
  bool get isAuthenticated => this is Authenticated;
}

/// Startup: whether a session can be restored is not yet known.
///
/// A router that treats this as "signed out" sends everyone to the entrance
/// for a frame and back, which on Web is a visible flash and a wrong URL in
/// history.
final class SessionUnknown extends Session {
  const SessionUnknown();
}

/// No session, and none is expected. The ordinary first-open state.
final class SignedOut extends Session {
  const SignedOut({this.reason});

  /// Why the session ended, when it ended rather than never began.
  ///
  /// The entrance uses this to say something true. It never carries
  /// relationship content — a person reading it may not be the account holder.
  final SignedOutReason? reason;
}

/// Why a session ended. Deliberately coarse: a reason that distinguishes
/// "revoked because your partner blocked you" from "expired" would leak
/// relationship state to whoever is holding the phone.
enum SignedOutReason {
  /// The person asked to sign out.
  requested,

  /// The refresh token was rejected or had expired.
  expired,
}

/// A live session. The access token lives here and only here, in memory.
final class Authenticated extends Session {
  const Authenticated({required this.accessToken});

  final String accessToken;

  /// Who this session belongs to, read from the token's `sub`.
  ///
  /// Not a security claim — the server re-derives the actor from the token on
  /// every request and never trusts a client-supplied id. This is for the one
  /// place a screen legitimately needs to name itself in a request body:
  /// assigning the first rhythm to the person setting it up.
  ///
  /// Null rather than throwing on a malformed token: a screen should show a
  /// recoverable failure, not crash, and the transport will reject the
  /// request anyway.
  String? get userId {
    final parts = accessToken.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = parts[1];
      final padded = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final json = utf8.decode(base64Url.decode(padded));
      final sub = (jsonDecode(json) as Map<String, dynamic>)['sub'];
      return sub is String && sub.isNotEmpty ? sub : null;
    } on Object {
      return null;
    }
  }
}
