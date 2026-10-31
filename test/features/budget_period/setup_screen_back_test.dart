import 'package:daily_tracking/app/routes.dart';
import 'package:daily_tracking/features/budget_period/presentation/setup_screen.dart';
import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:daily_tracking/features/daily_tracking/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_repositories.dart';

void main() {
  late FakeFixedExpenseRepository fixedRepo;

  Future<void> pumpScreen(WidgetTester tester, {int income = 3000000}) async {
    final periodRepo = FakeBudgetPeriodRepository();
    final periodId = await periodRepo.startNew(
      BudgetPeriod(
        totalIncome: income,
        startDate: DateTime(2026, 10, 1),
        daysCount: 30,
      ),
    );
    fixedRepo = FakeFixedExpenseRepository();
    await fixedRepo.add(
      FixedExpense(periodId: periodId, name: 'Kos', amount: 1000000),
    );

    // Satu halaman di tumpukan, sama seperti saat dibuka lewat context.go.
    final router = GoRouter(
      initialLocation: setupPath,
      routes: [
        GoRoute(
          path: setupPath,
          builder: (context, state) => const SetupScreen(),
        ),
        GoRoute(
          path: homePath,
          builder: (context, state) => const Scaffold(body: Text('Beranda')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetPeriodRepositoryProvider.overrideWithValue(periodRepo),
          fixedExpenseRepositoryProvider.overrideWithValue(fixedRepo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pressSystemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<void> tapFinish(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Selesai'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
  }

  Future<void> addExpense(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Wifi');
    await tester.enterText(find.byType(TextFormField).at(1), '300000');
    await tester.tap(find.text('Tambah tagihan'));
    await tester.pumpAndSettle();
  }

  testWidgets('kembali tanpa perubahan langsung ke beranda', (tester) async {
    await pumpScreen(tester);

    await pressSystemBack(tester);

    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('tombol kembali di AppBar berperilaku sama', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('kembali setelah menambah tagihan meminta konfirmasi', (
    tester,
  ) async {
    await pumpScreen(tester);
    await addExpense(tester);

    await pressSystemBack(tester);
    expect(find.text('Buang perubahan?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Wifi'), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);

    await pressSystemBack(tester);
    await tester.tap(find.text('Buang'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(fixedRepo.items.map((e) => e.name), ['Kos']);
  });

  testWidgets('input yang belum ditambahkan juga meminta konfirmasi', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Wifi');

    await pressSystemBack(tester);

    expect(find.text('Buang perubahan?'), findsOneWidget);
  });

  testWidgets('menghapus tagihan tidak tersimpan sebelum Selesai', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Hapus Kos'));
    await tester.pumpAndSettle();
    expect(fixedRepo.items, hasLength(1));

    await tapFinish(tester);

    expect(find.text('Beranda'), findsOneWidget);
    expect(fixedRepo.items, isEmpty);
  });

  testWidgets('tambah lalu hapus lagi dianggap tidak ada perubahan', (
    tester,
  ) async {
    await pumpScreen(tester);
    await addExpense(tester);

    await tester.tap(find.byTooltip('Hapus Wifi'));
    await tester.pumpAndSettle();
    await pressSystemBack(tester);

    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('Selesai menyimpan tanpa konfirmasi lalu ke beranda', (
    tester,
  ) async {
    await pumpScreen(tester);
    await addExpense(tester);

    await tapFinish(tester);

    expect(find.text('Buang perubahan?'), findsNothing);
    expect(find.text('Beranda'), findsOneWidget);
    expect(fixedRepo.items.map((e) => e.name), ['Kos', 'Wifi']);
  });

  testWidgets('Selesai ikut menyimpan isi form yang valid', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Wifi');
    await tester.enterText(find.byType(TextFormField).at(1), '300000');

    await tapFinish(tester);

    expect(find.text('Beranda'), findsOneWidget);
    expect(fixedRepo.items.map((e) => e.name), ['Kos', 'Wifi']);
  });

  testWidgets('Selesai bertahan di halaman jika isi form tidak valid', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Wifi');

    await tapFinish(tester);

    expect(find.text('Beranda'), findsNothing);
    expect(fixedRepo.items.map((e) => e.name), ['Kos']);
  });

  testWidgets('Selesai bertahan jika isi form menghabiskan sisa dana', (
    tester,
  ) async {
    await pumpScreen(tester, income: 1500000);
    await tester.enterText(find.byType(TextFormField).at(0), 'Wifi');
    await tester.enterText(find.byType(TextFormField).at(1), '600000');

    await tapFinish(tester);

    expect(find.text('Beranda'), findsNothing);
    expect(fixedRepo.items.map((e) => e.name), ['Kos']);
  });
}
