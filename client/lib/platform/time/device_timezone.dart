import 'device_timezone_io.dart'
    if (dart.library.js_interop) 'device_timezone_web.dart';

/// The device's IANA timezone name, or null when it cannot be determined.
///
/// `REQ-TIME-001` needs an IANA name — `America/Los_Angeles`, not `PST` and
/// never a bare offset. A fixed offset survives every type check and then
/// silently moves someone's relationship day when the clocks change, months
/// after anyone was looking.
///
/// Dart's `DateTime.timeZoneName` gives an abbreviation, so it is no use here.
/// Null rather than a guess: the activation wizard would rather say it could
/// not read the zone than create a Dynamic in the wrong one.
String? deviceTimezone() => readDeviceTimezone();
