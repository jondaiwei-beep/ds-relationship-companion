import 'callback_params_io.dart'
    if (dart.library.js_interop) 'callback_params_web.dart';

/// What a magic-link callback carries, read from wherever the platform put it.
///
/// The server builds the link as `/auth/callback#ml=<token>&flow=<id>`, and the
/// **fragment** is deliberate: it is never sent in the HTTP request or in a
/// `Referer` header, so the one-time token does not reach a server log or an
/// analytics beacon on its way past.
///
/// That also means `go_router` cannot see it. On Web it comes from the browser
/// URL; on Android the App Link is delivered as a whole URI and parsed the
/// same way.
class CallbackParams {
  const CallbackParams({required this.token, required this.flowId});

  final String token;
  final String flowId;

  /// Parse a full callback URL. Returns null when either half is missing —
  /// a link with a token and no flow cannot be completed, and guessing would
  /// mean asking the server to consume a token this device never requested.
  static CallbackParams? parse(String url) {
    final fragment = Uri.tryParse(url)?.fragment;
    if (fragment == null || fragment.isEmpty) return null;
    final values = Uri.splitQueryString(fragment);
    final token = values['ml'];
    final flowId = values['flow'];
    if (token == null || token.isEmpty) return null;
    if (flowId == null || flowId.isEmpty) return null;
    return CallbackParams(token: token, flowId: flowId);
  }

  /// The callback this process was opened with, if any.
  static CallbackParams? current() => readCurrentCallback();

  /// Reads the launching link before the first frame.
  ///
  /// Android only exposes it asynchronously, and the callback screen asks for
  /// it during build. Without this the app opened on Today and the tapped
  /// link did nothing.
  static Future<void> prime() => primeLaunchLink();

  /// Links delivered while the app is already running.
  static Stream<Uri> incoming() => incomingLinks();

  /// Hold a warm link so [current] can answer for it too.
  static void remember(Uri uri) => rememberIncoming(uri);
}
