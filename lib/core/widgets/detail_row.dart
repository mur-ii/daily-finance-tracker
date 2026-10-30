import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Baris label–nilai di dalam card ringkasan. Label memakai Text Secondary,
/// nilai memakai Inter Medium dengan angka tabular agar sejajar.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;

  /// Tebalkan label dan nilai, mis. untuk baris total.
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final weight = emphasize ? FontWeight.w700 : FontWeight.w600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: emphasize
                    ? context.colors.onSurface
                    : context.semanticColors.textSecondary,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: weight,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
