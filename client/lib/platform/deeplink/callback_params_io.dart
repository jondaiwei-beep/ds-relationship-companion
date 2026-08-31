import 'package:app_links/app_links.dart';

import 'callback_params.dart';

/// Android, iOS and desktop.
///
/// This returned `null`. The Android manifest routes both link kinds to the
/// app correctly — an invite at `/invite/<token>`, a magic link at
/// `/auth/callback` — so Android handed the URI over and Dart dropped it on
/// the floor. The app opened on Today and the link the person tapped did
/// nothing at all, silently.
///
/// The launch URI is only available asynchronously here, so it is read once at
/// startup and cached; [readCurrentCallback] then answers synchronously for
/// the screen that asks during build, exactly as the Web reader does.
String? _launchUri;

CallbackParams? readCurrentCallback() =>
    _launchUri == null ? null : CallbackParams.parse(_launchUri!);

Future<void> primeLaunchLink() async {
  try {
    final uri = await AppLinks().getInitialLink();
    _launchUri = uri?.toString();
  } on Object {
    // A device that will not report its launch intent is not a reason to
    // refuse to start.
    _launchUri = null;
  }
}

/// Remember a link that arrived while the app was already running.
///
/// The callback screen reads the token synchronously from whatever this
/// module holds. Without this, a magic link tapped while the app was in the
/// background would route to the callback screen with nothing to consume:
/// go_router drops the fragment, and the fragment is where the token is.
void rememberIncoming(Uri uri) => _launchUri = uri.toString();

/// Links that arrive while the app is already running.
///
/// A cold-start read alone is not enough: tapping an invite while the app sits
/// in the background delivers the URI to the running process, and nothing
/// would ever read it.
Stream<Uri> incomingLinks() => AppLinks().uriLinkStream;
