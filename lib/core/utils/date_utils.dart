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
