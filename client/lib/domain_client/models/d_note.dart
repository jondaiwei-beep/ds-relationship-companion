import 'package:freezed_annotation/freezed_annotation.dart';

part 'd_note.freezed.dart';
part 'd_note.g.dart';

/// The D's own note to self. The s never receives one (invariant 8).
@freezed
abstract class DNote with _$DNote {
  const factory DNote({
    required String id,
    required String body,
    DateTime? remindAt,
    DateTime? remindedAt,
    DateTime? doneAt,
    required DateTime createdAt,
  }) = _DNote;

  factory DNote.fromJson(Map<String, dynamic> json) => _$DNoteFromJson(json);
}
