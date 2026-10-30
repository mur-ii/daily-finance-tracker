enum TransactionCategory { food, transport, shopping, other }

/// Siklus gajian. Nominal uang disimpan sebagai Rupiah bulat (int).
class BudgetPeriod {
  const BudgetPeriod({
    this.id,
    required this.totalIncome,
    required this.startDate,
    required this.daysCount,
    this.isActive = true,
  });

  final int? id;
  final int totalIncome;
  final DateTime startDate;
  final int daysCount;
  final bool isActive;

  /// Hari terakhir periode (inklusif).
  DateTime get endDate =>
      DateTime(startDate.year, startDate.month, startDate.day + daysCount - 1);
}

/// Tagihan wajib yang dipotong dari saldo awal.
class FixedExpense {
  const FixedExpense({
    this.id,
    required this.periodId,
    required this.name,
    required this.amount,
  });

  final int? id;
  final int periodId;
  final String name;
  final int amount;
}

/// Pengeluaran jajan harian.
class DailyTransaction {
  const DailyTransaction({
    this.id,
    required this.periodId,
    required this.date,
    required this.amount,
    required this.category,
    this.note = '',
  });

  final int? id;
  final int periodId;
  final DateTime date;
  final int amount;
  final TransactionCategory category;
  final String note;
}
