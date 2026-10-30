import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Warna feedback (hemat / mendekati limit / overbudget) dan token
/// neo-brutalism yang tidak ada di [ColorScheme]. Diakses via
/// `Theme.of(context).extension<AppSemanticColors>()` atau
/// `context.semanticColors`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.textSecondary,
    required this.border,
    required this.highlight,
  });

  static const light = AppSemanticColors(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    textSecondary: AppColors.textSecondary,
    border: AppColors.ink,
    highlight: AppColors.yellow,
  );

  final Color success;
  final Color warning;
  final Color danger;

  final Color textSecondary;

  /// Border & hard shadow (hitam pekat).
  final Color border;

  /// Aksen kuning untuk item aktif, tag, dan baris terpilih.
  final Color highlight;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? textSecondary,
    Color? border,
    Color? highlight,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}
