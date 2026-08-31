import 'package:flutter_timezone/flutter_timezone.dart';

/// Android, iOS and desktop, via a platform channel.
///
/// There is no synchronous route to an IANA name here — the answer comes from
/// `java.time.ZoneId.systemDefault()` across a channel — so the synchronous
/// reader returns whatever startup cached and the async one does the work.
String? readDeviceTimezone() => null;

Future<String?> resolveDeviceTimezone() async {
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    final id = zone.identifier;
    // A name, not an abbreviation or an offset. `Etc/GMT+8` is a valid IANA
    // id that does not observe daylight saving, which is exactly the silent
    // drift REQ-TIME-001 exists to prevent.
    return id.contains('/') && !id.startsWith('Etc/') ? id : null;
  } on Object {
    return null;
  }
}
