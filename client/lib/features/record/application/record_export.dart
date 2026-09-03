import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Where an exported CSV goes once it is in hand: the system share sheet by
/// default. Tests swap in a sink that only remembers what it was given.
typedef ExportSink = Future<void> Function(String filename, String csv);

final exportSinkProvider = Provider<ExportSink>((ref) => shareCsv);

/// Hands the CSV to the platform share sheet as a file. No temp directory of
/// our own — `XFile.fromData` works the same on the phone and on the Web.
Future<void> shareCsv(String filename, String csv) async {
  final file = XFile.fromData(
    utf8.encode(csv),
    mimeType: 'text/csv',
    name: filename,
  );
  await SharePlus.instance.share(ShareParams(files: [file], fileNameOverrides: [filename]));
}
