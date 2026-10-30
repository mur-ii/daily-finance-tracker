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
      ],
    );
    addTearDown(container.dispose);
  });

  test('awalnya belum ada periode aktif dan tagihan kosong', () async {
    expect(await container.read(activePeriodProvider.future), isNull);
    expect(await container.read(fixedExpensesProvider.future), isEmpty);
  });

  test('startNew membuat periode aktif', () async {
    await container.read(activePeriodProvider.future);
    await container
        .read(activePeriodProvider.notifier)
        .startNew(
          totalIncome: 3000000,
          startDate: DateTime(2026, 10, 1),
          daysCount: 30,
        );

    final period = await container.read(activePeriodProvider.future);
    expect(period?.totalIncome, 3000000);
    expect(period?.id, isNotNull);
  });

  test('add dan remove tagihan wajib', () async {
    await container.read(activePeriodProvider.future);
    await container
        .read(activePeriodProvider.notifier)
        .startNew(
          totalIncome: 3000000,
          startDate: DateTime(2026, 10, 1),
          daysCount: 30,
        );

    final notifier = container.read(fixedExpensesProvider.notifier);
    await notifier.add(name: '  Kos ', amount: 1000000);
    var list = await container.read(fixedExpensesProvider.future);
    expect(list.single.name, 'Kos');

    await notifier.remove(list.single.id!);
    list = await container.read(fixedExpensesProvider.future);
    expect(list, isEmpty);
  });

  test(
    'riwayat memuat periode lama dan baru dengan datanya masing-masing',
    () async {
      await container.read(activePeriodProvider.future);
      final notifier = container.read(activePeriodProvider.notifier);
      await notifier.startNew(
        totalIncome: 3000000,
        startDate: DateTime(2026, 9, 1),
        daysCount: 30,
      );
      final oldId = (await container.read(activePeriodProvider.future))!.id!;
      await container
          .read(transactionRepositoryProvider)
          .add(
            DailyTransaction(
              periodId: oldId,
              date: DateTime(2026, 9, 2),
              amount: 25000,
              category: TransactionCategory.food,
            ),
          );
      await notifier.startNew(
        totalIncome: 4000000,
        startDate: DateTime(2026, 10, 1),
        daysCount: 30,
      );

      final history = await container.read(periodHistoryProvider.future);
      expect(history.map((d) => d.period.totalIncome), [4000000, 3000000]);
      expect(history.first.period.isActive, isTrue);
      expect(history.last.summary.totalSpent, 25000);
      expect(history.first.transactions, isEmpty);

      final detail = await container.read(periodDetailProvider(oldId).future);
      expect(detail?.transactions.single.amount, 25000);
      expect(await container.read(periodDetailProvider(999).future), isNull);
    },
  );

  test('add tanpa periode aktif melempar StateError', () async {
    await container.read(fixedExpensesProvider.future);
    expect(
      () => container
          .read(fixedExpensesProvider.notifier)
          .add(name: 'Kos', amount: 1),
      throwsStateError,
    );
  });
}
