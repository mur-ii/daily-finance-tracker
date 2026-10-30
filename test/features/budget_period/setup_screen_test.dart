import 'package:daily_tracking/core/utils/money.dart';
import 'package:daily_tracking/features/budget_period/presentation/setup_screen.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_repositories.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetPeriodRepositoryProvider.overrideWithValue(
            FakeBudgetPeriodRepository(),
          ),
          fixedExpenseRepositoryProvider.overrideWithValue(
            FakeFixedExpenseRepository(),
          ),
        ],
        child: const MaterialApp(home: SetupScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('form periode menolak input kosong', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Simpan periode'));
    await tester.pump();

    expect(find.text('Masukkan nominal'), findsOneWidget);
  });

  testWidgets('setup periode lalu tambah tagihan menghitung sisa dana', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), '3000000');
    await tester.tap(find.text('Simpan periode'));
    await tester.pumpAndSettle();

    expect(find.text('Pengeluaran wajib'), findsOneWidget);
    expect(find.text(formatRupiah(3000000)), findsWidgets);

    await tester.enterText(find.byType(TextFormField).at(0), 'Kos');
    await tester.enterText(find.byType(TextFormField).at(1), '1200000');
    await tester.tap(find.text('Tambah tagihan'));
    await tester.pumpAndSettle();

    expect(find.text('Kos'), findsOneWidget);
    expect(find.text(formatRupiah(1800000)), findsOneWidget);
    expect(find.text(formatRupiah(60000)), findsOneWidget);
  });
}
