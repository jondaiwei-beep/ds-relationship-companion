import 'dart:js_interop';

/// The browser's zone name, from `Intl.DateTimeFormat().resolvedOptions()`.
///
/// This is the one API that reports an IANA name rather than an abbreviation
/// or an offset, which is what `REQ-TIME-001` requires.
@JS('Intl.DateTimeFormat')
extension type _DateTimeFormat._(JSObject _) implements JSObject {
  external factory _DateTimeFormat();
  external _ResolvedOptions resolvedOptions();
}

extension type _ResolvedOptions._(JSObject _) implements JSObject {
  external String? get timeZone;
}

/// The web reader is already synchronous, so priming has nothing to do.
Future<String?> resolveDeviceTimezone() async => readDeviceTimezone();

String? readDeviceTimezone() {
  try {
    final zone = _DateTimeFormat().resolvedOptions().timeZone;
    return (zone == null || zone.isEmpty) ? null : zone;
  } on Object {
    return null;
  }
}
