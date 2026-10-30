import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import '../utils/money.dart';
import 'neo_box.dart';

/// Status visual sisa limit harian.
enum LimitStatus {
  /// Banyak tersisa: progress hitam.
  healthy,

  /// Mendekati limit: tag & progress kuning.
  warning,

  /// Overbudget: tag & progress merah, angka merah.
  over;

  /// [spentRatio] = terpakai / jatah (0..1+). Warning mulai di
  /// [warningThreshold].
  static LimitStatus from({
    required int remaining,
    required double spentRatio,
    double warningThreshold = 0.8,
  }) {
    if (remaining < 0) return LimitStatus.over;
    if (spentRatio >= warningThreshold) return LimitStatus.warning;
    return LimitStatus.healthy;
  }
}

/// Card utama dashboard: sisa limit harian dengan angka paling menonjol (H1),
/// progress bar pemakaian, dan baris detail opsional di bawahnya.
class HeroDailyLimitCard extends StatelessWidget {
  const HeroDailyLimitCard({
    super.key,
    required this.remaining,
    required this.spentRatio,
    this.label = 'Limit jajan hari ini',
    this.status,
    this.footer = const [],
  });

  /// Sisa limit hari ini dalam Rupiah (boleh negatif).
  final int remaining;

  /// Bagian yang sudah terpakai, 0..1 (di-clamp).
  final double spentRatio;

  final String label;

  /// Default dihitung dari [remaining] dan [spentRatio].
  final LimitStatus? status;

  /// Konten tambahan di bawah progress bar, mis. [HeroLimitDetailRow].
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semanticColors;
    final textTheme = context.textTheme;
    final resolved =
        status ??
        LimitStatus.from(remaining: remaining, spentRatio: spentRatio);

    final accent = switch (resolved) {
      LimitStatus.healthy => colors.primary,
      LimitStatus.warning => semantic.warning,
      LimitStatus.over => semantic.danger,
    };
    final amountColor = resolved == LimitStatus.over
        ? semantic.danger
        : AppColors.ink;

    return NeoBox(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (resolved != LimitStatus.healthy)
                _StatusTag(
                  label: resolved == LimitStatus.over
                      ? 'Overbudget'
                      : 'Hampir habis',
                  color: accent,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatRupiah(remaining),
              style: textTheme.headlineLarge?.copyWith(color: amountColor),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: const BoxDecoration(border: AppNeo.border),
            child: LinearProgressIndicator(
              value: spentRatio.clamp(0.0, 1.0),
              color: accent,
              backgroundColor: colors.surface,
              minHeight: 12,
              borderRadius: BorderRadius.zero,
              semanticsLabel: 'Limit terpakai',
            ),
          ),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: AppNeo.borderWidth),
            const SizedBox(height: AppSpacing.sm),
            ...footer,
          ],
        ],
      ),
    );
  }
}

/// Tag kecil status di pojok kanan atas hero card.
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        border: AppNeo.border,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Baris label–nilai untuk [HeroDailyLimitCard.footer].
class HeroLimitDetailRow extends StatelessWidget {
  const HeroLimitDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: AppColors.ink),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
