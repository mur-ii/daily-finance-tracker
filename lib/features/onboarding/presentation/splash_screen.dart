import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/neo_box.dart';
import '../data/onboarding_prefs.dart';

const String _logoAsset = 'assets/images/logo_app.png';

/// Splash berlogo. User baru melihat logo lebih lama lalu masuk onboarding;
/// user lama hanya sekilas lalu langsung ke home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const firstTimeDelay = Duration(milliseconds: 2500);
  static const returningDelay = Duration(milliseconds: 500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    bool seen;
    try {
      seen = await hasSeenOnboarding();
    } catch (_) {
      // Prefs gagal dibaca: perlakukan sebagai user baru agar tidak macet.
      seen = false;
    }
    await Future<void>.delayed(
      seen ? SplashScreen.returningDelay : SplashScreen.firstTimeDelay,
    );
    // Widget bisa sudah dilepas dari tree selama menunggu.
    if (!mounted) return;
    context.go(seen ? homePath : onboardingPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoSize =
                (math.min(constraints.maxWidth, constraints.maxHeight) * 0.4)
                    .clamp(96.0, 220.0);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeoBox(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: SizedBox.square(
                        dimension: logoSize,
                        child: Image.asset(
                          _logoAsset,
                          fit: BoxFit.contain,
                          semanticLabel: 'Logo aplikasi',
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.account_balance_wallet_outlined,
                            size: logoSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Daily Finance Tracker',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
