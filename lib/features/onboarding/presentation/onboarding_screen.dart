import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/onboarding_prefs.dart';

class _OnboardingPage {
  const _OnboardingPage(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}

const List<_OnboardingPage> _pages = [
  _OnboardingPage(
    Icons.savings_outlined,
    'Atur anggaranmu',
    'Masukkan saldo awal, durasi, dan pengeluaran wajib sekali di awal.',
  ),
  _OnboardingPage(
    Icons.today_outlined,
    'Pantau jatah harian',
    'Lihat berapa yang aman dibelanjakan hari ini dan catat tiap transaksi.',
  ),
  _OnboardingPage(
    Icons.history,
    'Lihat riwayat periode',
    'Bandingkan periode sebelumnya untuk kebiasaan keuangan yang lebih baik.',
  ),
];

/// Perkenalan singkat untuk user yang baru pertama kali membuka aplikasi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await markOnboardingSeen();
    } catch (_) {
      // Gagal menyimpan hanya berarti onboarding tampil lagi nanti.
    }
    if (!mounted) return;
    context.go(homePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: _finishing ? null : _finish,
                  child: const Text('Lewati'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _PageContent(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _Dots(count: _pages.length, index: _index),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _isLast ? 'Mulai' : 'Lanjut',
                    isLoading: _finishing,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoBox(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Icon(page.icon, size: 72),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.semanticColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: i == index ? 24 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == index ? AppColors.ink : AppColors.surface,
              border: AppNeo.border,
            ),
          ),
      ],
    );
  }
}
