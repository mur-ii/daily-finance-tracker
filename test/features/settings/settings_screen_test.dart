import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/providers.dart';
import 'package:daily_tracking/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_repositories.dart';

void main() {
  late FakeBudgetPeriodRepository periods;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'no_spend_days': ['2026-10-28'],
    });
    periods = FakeBudgetPeriodRepository();
    await periods.startNew(
      BudgetPeriod(
        totalIncome: 3000000,
        startDate: DateTime(2026, 10, 1),
        daysCount: 30,
      ),
    );
  });

  Future<void> pump(WidgetTester tester) async {
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
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hapus semua data butuh ketik HAPUS', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Hapus semua data'));
    await tester.pumpAndSettle();

    final confirm = find.widgetWithText(FilledButton, 'Hapus semua');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'HAPUS');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(periods.items, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('no_spend_days'), isNull);
  });

  testWidgets('pengingat default nonaktif', (tester) async {
    await pump(tester);
    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isFalse);
  });
}
