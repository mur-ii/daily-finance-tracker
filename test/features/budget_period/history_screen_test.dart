import 'package:daily_tracking/core/utils/money.dart';
import 'package:daily_tracking/core/widgets/neo_box.dart';
import 'package:daily_tracking/features/budget_period/presentation/history_detail_screen.dart';
import 'package:daily_tracking/features/budget_period/presentation/history_screen.dart';
import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_repositories.dart';

void main() {
  late FakeBudgetPeriodRepository periods;
  late FakeDailyTransactionRepository transactions;

  setUp(() {
    periods = FakeBudgetPeriodRepository();
    transactions = FakeDailyTransactionRepository();
  });

  Future<void> pump(WidgetTester tester, {int? detailId}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetPeriodRepositoryProvider.overrideWithValue(periods),
          fixedExpenseRepositoryProvider.overrideWithValue(
            FakeFixedExpenseRepository(),
          ),
          transactionRepositoryProvider.overrideWithValue(transactions),
          todayProvider.overrideWithValue(DateTime(2026, 10, 5, 9)),
        ],
        child: MaterialApp(
          home: detailId == null
              ? const HistoryScreen()
              : HistoryDetailScreen(periodId: detailId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<int> addPeriod(int income, DateTime start) => periods.startNew(
    BudgetPeriod(totalIncome: income, startDate: start, daysCount: 30),
  );

  testWidgets('kosong menampilkan pesan', (tester) async {
    await pump(tester);
    expect(find.text('Belum ada riwayat.'), findsOneWidget);
  });

  testWidgets('menampilkan periode arsip dan aktif', (tester) async {
    await addPeriod(3000000, DateTime(2026, 9, 1));
    await addPeriod(4000000, DateTime(2026, 10, 1));
    await pump(tester);

    expect(find.text('Aktif'), findsOneWidget);
    // Pemasukan dan sisa sama besar karena belum ada pengeluaran.
    expect(find.text(formatRupiah(3000000)), findsNWidgets(2));
    expect(find.text(formatRupiah(4000000)), findsNWidgets(2));
  });

  testWidgets('detail read-only menampilkan transaksi periode lama', (
    tester,
  ) async {
    final oldId = await addPeriod(3000000, DateTime(2026, 9, 1));
    await addPeriod(4000000, DateTime(2026, 10, 1));
    await transactions.add(
      DailyTransaction(
        periodId: oldId,
        date: DateTime(2026, 9, 2),
        amount: 25000,
        category: TransactionCategory.food,
      ),
    );
    await pump(tester, detailId: oldId);

    expect(find.text(formatRupiah(25000)), findsWidgets);
    expect(find.byType(NeoFab), findsNothing);
    expect(find.byTooltip('Hapus'), findsNothing);
  });

  testWidgets('periode aktif tidak bisa dihapus', (tester) async {
    final id = await addPeriod(3000000, DateTime(2026, 10, 1));
    await pump(tester, detailId: id);
    expect(find.byTooltip('Hapus periode'), findsNothing);
  });

  testWidgets('hapus periode arsip setelah konfirmasi', (tester) async {
    final oldId = await addPeriod(3000000, DateTime(2026, 9, 1));
    await addPeriod(4000000, DateTime(2026, 10, 1));
    await pump(tester, detailId: oldId);

    await tester.tap(find.byTooltip('Hapus periode'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();

    expect(await periods.getById(oldId), isNull);
    expect(periods.items, hasLength(1));
  });

  testWidgets('id tidak ditemukan', (tester) async {
    await pump(tester, detailId: 999);
    expect(find.text('Periode tidak ditemukan.'), findsOneWidget);
  });
}
