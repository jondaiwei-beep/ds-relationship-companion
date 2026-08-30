/// Android and desktop.
///
/// Not implemented yet: this returns null so the wizard reports honestly
/// rather than inventing a zone. The Android lookup is a one-line platform
/// channel to `java.time.ZoneId.systemDefault()`, and it is the last thing
/// standing between activation and a real device.
String? readDeviceTimezone() => null;
