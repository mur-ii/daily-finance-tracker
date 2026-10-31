import '../../../core/utils/date_utils.dart';
import 'entities.dart';

/// Hasil kalkulasi anggaran untuk satu hari.
class BudgetSummary {
  const BudgetSummary({
    required this.netFunds,
    required this.dailyBase,
    required this.dayNumber,
    required this.isPeriodEnded,
    required this.accumulatedAllowance,
    required this.totalSpent,
    required this.todayLimit,
    required this.tomorrowLimit,
  });

  /// Saldo awal dikurangi total pengeluaran wajib.
  final int netFunds;

  /// Jatah flat per hari (tanpa rollover).
  final int dailyBase;

  /// Hari ke-X dalam periode, di-clamp ke 1..daysCount.
  final int dayNumber;

  /// True jika hari ini sudah melewati hari terakhir periode.
  final bool isPeriodEnded;

  final int accumulatedAllowance;
  final int totalSpent;

  /// Sisa uang yang boleh dipakai hari ini; negatif berarti overbudget.
  final int todayLimit;

  /// Proyeksi limit besok jika hari ini tidak ada pengeluaran tambahan.
  /// Null jika hari ini adalah hari terakhir (atau sudah lewat).
  final int? tomorrowLimit;
}

/// Kalkulasi murni (tanpa Flutter/DB) sesuai docs/03_Calculation_Logic.md.
class BudgetCalculator {
  const BudgetCalculator._();

  static BudgetSummary calculate({
    required BudgetPeriod period,
    required List<FixedExpense> fixedExpenses,
    required List<DailyTransaction> transactions,
    required DateTime today,
  }) {
    if (period.daysCount <= 0) {
      throw ArgumentError.value(
        period.daysCount,
        'period.daysCount',
        'must be greater than 0',
      );
    }

    final netFunds =
        period.totalIncome -
        fixedExpenses.fold<int>(0, (sum, e) => sum + e.amount);
    final dailyBase = netFunds ~/ period.daysCount;

    final rawDay = daysBetween(period.startDate, today) + 1;
    final dayNumber = rawDay.clamp(1, period.daysCount).toInt();
    final todayDate = dateOnly(today);
    final cutoff = rawDay > period.daysCount
        ? dateOnly(period.startDate).add(Duration(days: period.daysCount - 1))
        : todayDate;

    int allowanceFor(int day) =>
        // Sisa pembagian integer dimasukkan ke hari terakhir.
        day == period.daysCount ? netFunds : dailyBase * day;

    int spentUntil(DateTime date) => transactions
        .where((t) => !dateOnly(t.date).isAfter(date))
        .fold<int>(0, (sum, t) => sum + t.amount);

    final accumulated = allowanceFor(dayNumber);
    final spent = spentUntil(cutoff);

    return BudgetSummary(
      netFunds: netFunds,
      dailyBase: dailyBase,
      dayNumber: dayNumber,
      isPeriodEnded: rawDay > period.daysCount,
      accumulatedAllowance: accumulated,
      totalSpent: spent,
      todayLimit: accumulated - spent,
      tomorrowLimit: dayNumber >= period.daysCount
          ? null
          : allowanceFor(dayNumber + 1) - spent,
    );
  }
}
