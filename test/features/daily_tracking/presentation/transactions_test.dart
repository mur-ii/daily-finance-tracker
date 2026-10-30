import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_repositories.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        budgetPeriodRepositoryProvider.overrideWithValue(
          FakeBudgetPeriodRepository(),
        ),
        fixedExpenseRepositoryProvider.overrideWithValue(
          FakeFixedExpenseRepository(),
        ),
        transactionRepositoryProvider.overrideWithValue(
          FakeDailyTransactionRepository(),
        ),
        todayProvider.overrideWithValue(DateTime(2026, 10, 2, 14)),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> startPeriod({bool carryOver = false}) => container
      .read(activePeriodProvider.notifier)
      .startNew(
        totalIncome: 3000000,
        startDate: DateTime(2026, 10, 1),
        daysCount: 30,
        carryOverFixedExpenses: carryOver,
      );

  DailyTransaction tx(DateTime date, int amount) => DailyTransaction(
    periodId: 0,
    date: date,
    amount: amount,
    category: TransactionCategory.food,
    note: ' bakso ',
  );

  test('dashboard null sebelum ada periode', () async {
    expect(await container.read(dashboardProvider.future), isNull);
  });

  test('save menambah transaksi dan limit hari ini ter-update', () async {
    await container.read(activePeriodProvider.future);
    await startPeriod();

    var data = (await container.read(dashboardProvider.future))!;
    expect(data.summary.todayLimit, 200000); // 100000 * hari ke-2

    await container
        .read(transactionsProvider.notifier)
        .save(tx(DateTime(2026, 10, 2), 50000));

    data = (await container.read(dashboardProvider.future))!;
    expect(data.summary.todayLimit, 150000);
    expect(data.transactions.single.note, 'bakso');
  });

  test('save dengan id memperbarui, remove menghapus', () async {
    await container.read(activePeriodProvider.future);
    await startPeriod();
    final notifier = container.read(transactionsProvider.notifier);

    await notifier.save(tx(DateTime(2026, 10, 1), 10000));
    final saved = (await container.read(transactionsProvider.future)).single;

    await notifier.save(
      DailyTransaction(
        id: saved.id,
        periodId: saved.periodId,
        date: saved.date,
        amount: 25000,
        category: TransactionCategory.shopping,
      ),
    );
    var list = await container.read(transactionsProvider.future);
    expect(list.single.amount, 25000);
    expect(list.single.category, TransactionCategory.shopping);

    await notifier.remove(saved.id!);
    list = await container.read(transactionsProvider.future);
    expect(list, isEmpty);
  });

  test('tanggal di luar periode ditolak', () async {
    await container.read(activePeriodProvider.future);
    await startPeriod();
    final notifier = container.read(transactionsProvider.notifier);

    expect(
      () => notifier.save(tx(DateTime(2026, 9, 30), 1000)),
      throwsArgumentError,
    );
    expect(
      () => notifier.save(tx(DateTime(2026, 10, 31), 1000)),
      throwsArgumentError,
    );
    // Hari terakhir (30 hari dari 1 Okt = 30 Okt) masih valid.
    await notifier.save(tx(DateTime(2026, 10, 30), 1000));
  });

  test('periode baru menonaktifkan lama dan menyalin tagihan wajib', () async {
    await container.read(activePeriodProvider.future);
    await startPeriod();
    await container
        .read(fixedExpensesProvider.notifier)
        .add(name: 'Kos', amount: 1000000);
    final oldId = (await container.read(activePeriodProvider.future))!.id;

    await startPeriod(carryOver: true);

    final period = (await container.read(activePeriodProvider.future))!;
    expect(period.id, isNot(oldId));
    final fixed = await container.read(fixedExpensesProvider.future);
    expect(fixed.single.name, 'Kos');
    expect(fixed.single.periodId, period.id);
  });

  test('periode baru tanpa carry-over mulai dengan tagihan kosong', () async {
    await container.read(activePeriodProvider.future);
    await startPeriod();
    await container
        .read(fixedExpensesProvider.notifier)
        .add(name: 'Kos', amount: 1000000);

    await startPeriod();

    expect(await container.read(fixedExpensesProvider.future), isEmpty);
  });

  test('edit tagihan wajib', () async {
    await container.read(activePeriodProvider.future);
    await startPeriod();
    final notifier = container.read(fixedExpensesProvider.notifier);
    await notifier.add(name: 'Kos', amount: 1000000);
    final item = (await container.read(fixedExpensesProvider.future)).single;

    await notifier.edit(item, name: ' Kos Baru ', amount: 1200000);

    final edited = (await container.read(fixedExpensesProvider.future)).single;
    expect(edited.name, 'Kos Baru');
    expect(edited.amount, 1200000);
  });
}
