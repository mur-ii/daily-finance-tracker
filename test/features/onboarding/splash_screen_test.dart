import 'package:daily_tracking/app/routes.dart';
import 'package:daily_tracking/features/onboarding/presentation/onboarding_screen.dart';
import 'package:daily_tracking/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: splashPath,
    routes: [
      GoRoute(path: splashPath, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: onboardingPath,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: homePath,
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('user baru diarahkan ke onboarding setelah delay', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app());

    await tester.pump(SplashScreen.returningDelay);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(SplashScreen.firstTimeDelay);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('user lama langsung ke home setelah splash singkat', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    await tester.pumpWidget(_app());

    await tester.pump(SplashScreen.returningDelay);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('tombol Lewati menyimpan flag lalu ke home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app());
    await tester.pump(SplashScreen.firstTimeDelay);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_seen_onboarding'), isTrue);
  });
}
