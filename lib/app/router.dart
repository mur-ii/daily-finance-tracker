import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/neo_background.dart';
import '../features/about/presentation/about_screen.dart';
import '../features/budget_period/presentation/history_detail_screen.dart';
import '../features/budget_period/presentation/history_screen.dart';
import '../features/budget_period/presentation/new_period_screen.dart';
import '../features/budget_period/presentation/setup_screen.dart';
import '../features/daily_tracking/presentation/home_screen.dart';
import '../features/daily_tracking/presentation/providers.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'routes.dart';

/// Satu-satunya tempat definisi route. Layar fitur didaftarkan di sini.
///
/// Selama belum ada periode aktif, semua route diarahkan ke setup.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(activePeriodProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: splashPath,
    refreshListenable: refresh,
    redirect: (context, state) {
      // Splash & onboarding mengatur navigasinya sendiri.
      final location = state.matchedLocation;
      if (location == splashPath || location == onboardingPath) return null;
      final period = ref.read(activePeriodProvider);
      if (period.isLoading) return null;
      final needsSetup = period.value == null;
      if (needsSetup && state.matchedLocation != setupPath) return setupPath;
      return null;
    },
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const NeoBackground(child: SplashScreen()),
      ),
      GoRoute(
        path: onboardingPath,
        builder: (context, state) =>
            const NeoBackground(child: OnboardingScreen()),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const NeoBackground(child: HomeScreen()),
      ),
      GoRoute(
        path: setupPath,
        builder: (context, state) => const NeoBackground(child: SetupScreen()),
      ),
      GoRoute(
        path: newPeriodPath,
        builder: (context, state) =>
            const NeoBackground(child: NewPeriodScreen()),
      ),
      GoRoute(
        path: historyPath,
        builder: (context, state) =>
            const NeoBackground(child: HistoryScreen()),
      ),
      GoRoute(
        path: historyDetailPattern,
        builder: (context, state) => NeoBackground(
          child: HistoryDetailScreen(
            periodId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
          ),
        ),
      ),
      GoRoute(
        path: aboutPath,
        builder: (context, state) => const NeoBackground(child: AboutScreen()),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) =>
            const NeoBackground(child: SettingsScreen()),
      ),
    ],
  );
});
