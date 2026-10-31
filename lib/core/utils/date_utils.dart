import 'package:intl/intl.dart';

/// Locale tampilan tanggal; datanya dimuat di `main` lewat
/// `initializeDateFormatting`.
const String appLocale = 'id_ID';

/// Menghapus komponen jam sehingga perbandingan hanya berdasarkan tanggal.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Selisih hari kalender antara [from] dan [to] (negatif jika [to] < [from]).
///
/// Dihitung lewat UTC agar tidak terpengaruh pergantian DST.
int daysBetween(DateTime from, DateTime to) {
  final a = dateOnly(from);
  final b = dateOnly(to);
  return DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

/// Contoh: `31 Oktober 2026`.
String formatDate(DateTime value) =>
    DateFormat('d MMMM y', appLocale).format(value);

/// Tanpa tahun, contoh: `31 Oktober`.
String formatDayMonth(DateTime value) =>
    DateFormat('d MMMM', appLocale).format(value);

/// Dengan nama hari, contoh: `Sabtu, 31 Oktober 2026`.
String formatFullDate(DateTime value) =>
    DateFormat('EEEE, d MMMM y', appLocale).format(value);
