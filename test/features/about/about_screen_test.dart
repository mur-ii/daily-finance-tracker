import 'package:daily_tracking/features/about/presentation/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Daily Finance Tracker',
      packageName: 'daily_tracking',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('menampilkan info aplikasi dan profil pengembang', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('Versi 1.0.0'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Muhammad Sadri'), 200);
    expect(find.text('Muhammad Sadri'), findsOneWidget);
  });

  testWidgets('tombol lisensi membuka halaman lisensi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Lisensi open source'), 200);
    await tester.tap(find.text('Lisensi open source'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
