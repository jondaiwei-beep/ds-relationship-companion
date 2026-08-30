import 'callback_params.dart';

/// Android delivers the App Link through the router, not through a global
/// location, so there is nothing ambient to read here.
CallbackParams? readCurrentCallback() => null;
