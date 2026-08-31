import 'package:web/web.dart' as web;

import 'callback_params.dart';

/// The browser's current URL, fragment included.
///
/// `go_router` strips the fragment before a route sees it, so the token has to
/// be read from the location directly.
CallbackParams? readCurrentCallback() =>
    CallbackParams.parse(web.window.location.href);

/// Nothing to prime: the browser URL is already there.
Future<void> primeLaunchLink() async {}

/// The browser has no equivalent — a new link is a new page load.
Stream<Uri> incomingLinks() => const Stream.empty();

/// Nothing to remember: the location bar is always current.
void rememberIncoming(Uri uri) {}
