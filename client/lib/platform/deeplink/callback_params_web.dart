import 'package:web/web.dart' as web;

import 'callback_params.dart';

/// The browser's current URL, fragment included.
///
/// `go_router` strips the fragment before a route sees it, so the token has to
/// be read from the location directly.
CallbackParams? readCurrentCallback() =>
    CallbackParams.parse(web.window.location.href);
