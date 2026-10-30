import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Judul section di dalam halaman (Poppins SemiBold) dengan jarak atas `lg`.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.textTheme.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Teks empty state di bawah [SectionHeader].
class EmptyHint extends StatelessWidget {
  const EmptyHint(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.semanticColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
