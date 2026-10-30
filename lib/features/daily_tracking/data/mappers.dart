import '../domain/entities.dart';

/// Tanggal disimpan sebagai TEXT `yyyy-MM-dd` (tanpa jam).
String encodeDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

DateTime decodeDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

extension BudgetPeriodMapper on BudgetPeriod {
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'total_income': totalIncome,
    'start_date': encodeDate(startDate),
    'days_count': daysCount,
    'is_active': isActive ? 1 : 0,
  };

  static BudgetPeriod fromMap(Map<String, Object?> map) => BudgetPeriod(
    id: map['id'] as int,
    totalIncome: map['total_income'] as int,
    startDate: decodeDate(map['start_date'] as String),
    daysCount: map['days_count'] as int,
    isActive: (map['is_active'] as int) == 1,
  );
}

extension FixedExpenseMapper on FixedExpense {
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'period_id': periodId,
    'name': name,
    'amount': amount,
  };

  static FixedExpense fromMap(Map<String, Object?> map) => FixedExpense(
    id: map['id'] as int,
    periodId: map['period_id'] as int,
    name: map['name'] as String,
    amount: map['amount'] as int,
  );
}

extension DailyTransactionMapper on DailyTransaction {
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'period_id': periodId,
    'date': encodeDate(date),
    'amount': amount,
    'category': category.name,
    'note': note,
  };

  static DailyTransaction fromMap(Map<String, Object?> map) => DailyTransaction(
    id: map['id'] as int,
    periodId: map['period_id'] as int,
    date: decodeDate(map['date'] as String),
    amount: map['amount'] as int,
    category: TransactionCategory.values.byName(map['category'] as String),
    note: map['note'] as String,
  );
}
