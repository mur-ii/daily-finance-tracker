import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'neo_box.dart';

/// Card info putih dengan blok ikon berwarna semantik (success / warning /
/// danger), mis. apresiasi rollover atau peringatan periode berakhir.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? message;

  /// Tombol opsional di kanan, mis. [TextButton].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return NeoBox(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 4,
        AppSpacing.sm + 4,
        AppSpacing.sm,
        AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.smAll,
              border: AppNeo.border,
            ),
            child: Icon(icon, color: AppColors.ink, size: 22),
          ),
          const SizedBox(width: AppSpacing.md - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.semanticColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
