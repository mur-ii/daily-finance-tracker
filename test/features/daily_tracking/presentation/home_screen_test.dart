import 'package:daily_tracking/core/theme/app_colors.dart';
import 'package:daily_tracking/core/utils/money.dart';
import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/home_screen.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_repositories.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpHome(WidgetTester tester) async {
    final periods = FakeBudgetPeriodRepository();
    await periods.startNew(
      BudgetPeriod(
        totalIncome: 3000000,
        startDate: DateTime(2026, 10, 1),
        daysCount: 30,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetPeriodRepositoryProvider.overrideWithValue(periods),
          fixedExpenseRepositoryProvider.overrideWithValue(
            FakeFixedExpenseRepository(),
          ),
          transactionRepositoryProvider.overrideWithValue(
            FakeDailyTransactionRepository(),
          ),
          todayProvider.overrideWithValue(DateTime(2026, 10, 1, 9)),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Color? colorOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  testWidgets('menampilkan limit hari ini dan empty state', (tester) async {
    await pumpHome(tester);

    expect(find.text('Limit jajan hari ini'), findsOneWidget);
    expect(find.text(formatRupiah(100000)), findsWidgets);
    expect(find.textContaining('Belum ada pengeluaran'), findsOneWidget);
  });

  testWidgets('catat pengeluaran memperbarui limit', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Catat pengeluaran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '40000');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text(formatRupiah(60000)), findsWidgets);
    expect(colorOf(tester, formatRupiah(60000)), isNot(AppColors.danger));
    expect(find.textContaining('Belum ada pengeluaran'), findsNothing);
  });

  testWidgets('pengeluaran melebihi limit tampil merah', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Catat pengeluaran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '150000');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Overbudget'), findsOneWidget);
    expect(colorOf(tester, formatRupiah(-50000)), AppColors.danger);
  });

  testWidgets('hapus transaksi mengembalikan limit', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Catat pengeluaran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '40000');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Gulir sampai habis agar tombol hapus tidak berada di bawah FAB.
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Belum ada pengeluaran'), findsOneWidget);
    expect(find.text(formatRupiah(100000)), findsWidgets);
  });

  testWidgets('streak: tandai hari tanpa jajan', (tester) async {
    await pumpHome(tester);

    expect(find.text('Mulai streak hari ini'), findsOneWidget);
    await tester.tap(find.text('Tidak jajan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 hari berturut-turut'), findsOneWidget);
    expect(find.text('Tidak jajan'), findsNothing);
  });

  testWidgets('streak: catat pengeluaran menghitung hari ini', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Catat pengeluaran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '40000');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 hari berturut-turut'), findsOneWidget);
  });
}
