import '../../../domain/relationship_day.dart';

/// One calendar month, `yyyy-MM` on the wire. Calendar arithmetic only — the
/// relationship day itself is the server's to name (invariant 7).
class YearMonth {
  const YearMonth(this.year, this.month);

  factory YearMonth.ofIsoDay(String isoDay) {
    final d = RelationshipDay.parseIsoDay(isoDay);
    return YearMonth(d.year, d.month);
  }

  final int year;
  final int month;

  YearMonth get previous => month == 1 ? YearMonth(year - 1, 12) : YearMonth(year, month - 1);
  YearMonth get next => month == 12 ? YearMonth(year + 1, 1) : YearMonth(year, month + 1);

  int get length => DateTime.utc(year, month + 1, 0).day;

  DateTime get firstDay => DateTime.utc(year, month, 1);
  DateTime get lastDay => DateTime.utc(year, month, length);

  String get firstIsoDay => RelationshipDay.isoDay(firstDay);
  String get lastIsoDay => RelationshipDay.isoDay(lastDay);

  /// Blank cells before the 1st in a Monday-first grid (0..6).
  int get leadingBlanks => (firstDay.weekday - DateTime.monday) % 7;

  bool contains(String isoDay) {
    final d = RelationshipDay.parseIsoDay(isoDay);
    return d.year == year && d.month == month;
  }

  String isoDayOf(int dayOfMonth) => RelationshipDay.isoDay(DateTime.utc(year, month, dayOfMonth));

  /// `yyyy-MM`.
  String get wire => '$year-${month.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => wire;
}

/// The Monday..Sunday week around a relationship day, as `yyyy-MM-dd` bounds.
({String from, String to}) weekAround(String isoDay) {
  final d = RelationshipDay.parseIsoDay(isoDay);
  final monday = DateTime.utc(d.year, d.month, d.day - (d.weekday - DateTime.monday));
  final sunday = DateTime.utc(monday.year, monday.month, monday.day + 6);
  return (from: RelationshipDay.isoDay(monday), to: RelationshipDay.isoDay(sunday));
}

int compareIsoDays(String a, String b) => a.compareTo(b);

/// [isoDay] shifted by [days] (negative goes back), still `yyyy-MM-dd`.
String shiftIsoDay(String isoDay, int days) {
  final d = RelationshipDay.parseIsoDay(isoDay);
  return RelationshipDay.isoDay(DateTime.utc(d.year, d.month, d.day + days));
}
