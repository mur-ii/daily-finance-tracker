import 'package:daily_tracking/core/widgets/app_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ValueNotifier<DateTime?>> _open(
  WidgetTester tester, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  final result = ValueNotifier<DateTime?>(null);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result.value = await showAppDatePicker(
                context,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
              );
            },
            child: const Text('Buka'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Buka'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('memilih tanggal mengembalikan tanggal itu', (tester) async {
    final result = await _open(
      tester,
      initialDate: DateTime(2026, 10, 15),
      firstDate: DateTime(2026, 10, 1),
      lastDate: DateTime(2026, 10, 31),
    );

    await tester.tap(find.text('20'));
    await tester.pump();
    expect(find.text('Selasa, 20 Oktober 2026'), findsOneWidget);

    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(result.value, DateTime(2026, 10, 20));
  });

  testWidgets('Batal mengembalikan null', (tester) async {
    final result = await _open(
      tester,
      initialDate: DateTime(2026, 10, 15),
      firstDate: DateTime(2026, 10, 1),
      lastDate: DateTime(2026, 10, 31),
    );

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(result.value, isNull);
  });

  testWidgets('minggu dimulai dari Senin', (tester) async {
    await _open(
      tester,
      initialDate: DateTime(2026, 10, 15),
      firstDate: DateTime(2026, 10, 1),
      lastDate: DateTime(2026, 10, 31),
    );

    // 5 Oktober 2026 hari Senin dan 11 Oktober hari Minggu: satu baris hanya
    // bila minggu dimulai Senin.
    final monday = tester.getCenter(find.text('5'));
    final sunday = tester.getCenter(find.text('11'));
    expect(monday.dy, sunday.dy);
    expect(monday.dx, lessThan(sunday.dx));
    expect(
      tester.getCenter(find.text('SEN')).dx,
      lessThan(tester.getCenter(find.text('MIN')).dx),
    );
  });

  testWidgets('tanggal awal di luar rentang tidak membuat error', (
    tester,
  ) async {
    final result = await _open(
      tester,
      initialDate: DateTime(2026, 12, 1),
      firstDate: DateTime(2026, 10, 1),
      lastDate: DateTime(2026, 10, 31),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(result.value, DateTime(2026, 10, 31));
  });
}
