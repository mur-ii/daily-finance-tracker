import 'package:daily_tracking/features/daily_tracking/domain/budget_calculator.dart';
import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 10, 1);

  BudgetPeriod period({int income = 3000000, int days = 30}) => BudgetPeriod(
    id: 1,
    totalIncome: income,
    startDate: start,
    daysCount: days,
  );

  FixedExpense fixed(int amount) =>
      FixedExpense(periodId: 1, name: 'Kos', amount: amount);

  DailyTransaction tx(DateTime date, int amount) => DailyTransaction(
    periodId: 1,
    date: date,
    amount: amount,
    category: TransactionCategory.food,
  );

  BudgetSummary run({
    BudgetPeriod? p,
    List<FixedExpense> fixedExpenses = const [],
    List<DailyTransaction> txs = const [],
    required DateTime today,
  }) => BudgetCalculator.calculate(
    period: p ?? period(),
    fixedExpenses: fixedExpenses,
    transactions: txs,
    today: today,
  );

  test('hari pertama tanpa pengeluaran: limit = jatah harian', () {
    final s = run(fixedExpenses: [fixed(1200000)], today: start);
    expect(s.netFunds, 1800000);
    expect(s.dailyBase, 60000);
    expect(s.dayNumber, 1);
    expect(s.todayLimit, 60000);
    expect(s.tomorrowLimit, 120000);
  });

  test('jam pada hari yang sama tidak memengaruhi hari ke-X', () {
    final s = run(today: DateTime(2026, 10, 1, 23, 59));
    expect(s.dayNumber, 1);
  });

  test('rollover: sisa hari sebelumnya digulung', () {
    final s = run(txs: [tx(start, 40000)], today: DateTime(2026, 10, 2));
    // basis 100000 * 2 - 40000
    expect(s.todayLimit, 160000);
  });

  test('overbudget saat pengeluaran melebihi akumulasi jatah', () {
    final s = run(txs: [tx(start, 150000)], today: start);
    expect(s.todayLimit, -50000);
  });

  test('transaksi setelah hari ini tidak dihitung', () {
    final s = run(
      txs: [tx(DateTime(2026, 10, 5), 99999)],
      today: DateTime(2026, 10, 2),
    );
    expect(s.totalSpent, 0);
  });

  test('pembagian tidak habis: sisa masuk ke hari terakhir', () {
    final p = period(income: 100, days: 3);
    final last = run(p: p, today: DateTime(2026, 10, 3));
    expect(last.dailyBase, 33);
    expect(last.todayLimit, 100);
    expect(last.tomorrowLimit, isNull);
  });

  test('setelah periode berakhir: clamp ke hari terakhir', () {
    final s = run(
      p: period(days: 10),
      txs: [tx(DateTime(2026, 10, 3), 1000)],
      today: DateTime(2026, 12, 1),
    );
    expect(s.isPeriodEnded, isTrue);
    expect(s.dayNumber, 10);
    expect(s.todayLimit, 3000000 - 1000);
  });

  test('sisa dana negatif menghasilkan limit negatif', () {
    final s = run(fixedExpenses: [fixed(4000000)], today: start);
    expect(s.netFunds, -1000000);
    expect(s.todayLimit, isNegative);
  });

  test('daysCount 0 melempar ArgumentError', () {
    expect(() => run(p: period(days: 0), today: start), throwsArgumentError);
  });
}
