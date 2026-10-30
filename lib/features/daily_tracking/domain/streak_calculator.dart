import '../../../core/utils/date_utils.dart';

/// Menghitung streak pencatatan: jumlah hari berturut-turut yang tercatat
/// (ada transaksi atau ditandai "tidak jajan").
class StreakCalculator {
  const StreakCalculator._();

  /// Streak berakhir hari ini, atau kemarin jika hari ini belum tercatat
  /// (supaya streak tidak langsung putus sebelum user sempat mencatat).
  static int calculate(Iterable<DateTime> recordedDays, DateTime today) {
    final days = {for (final d in recordedDays) dateOnly(d)};
    var cursor = dateOnly(today);
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }
}
