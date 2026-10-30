import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_semantic_colors.dart';

/// ThemeData global neo-brutalism sesuai docs/04_design.md.
///
/// Hard shadow tidak bisa diatur lewat ThemeData (elevation Material selalu
/// blur), jadi card, tombol utama, dan FAB memakai `NeoBox` / `NeoButton`.
/// Tema di sini menyamakan sisanya: border hitam 2px, sudut 4px, tanpa
/// elevation.
abstract final class AppTheme {
  static final ThemeData light = _light();

  static ThemeData _light() {
    const colors = ColorScheme.light(
      // Tombol utama & state aktif: hitam pekat dengan teks putih.
      primary: AppColors.ink,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.yellow,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.blue,
      onSecondary: AppColors.surface,
      error: AppColors.danger,
      onError: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.ink,
      outlineVariant: AppColors.ink,
      surfaceTint: Colors.transparent,
      shadow: AppColors.ink,
    );
    const semantic = AppSemanticColors.light;
    final textTheme = _textTheme(colors);
    final labelStyle = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      // Latar kuning digambar oleh NeoBackground di belakang Scaffold.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: AppColors.surface,
      textTheme: textTheme,
      extensions: const [semantic],
      splashFactory: NoSplash.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: const Border(bottom: AppNeo.side),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        shape: AppRadius.smShape,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: AppRadius.smShape,
          textStyle: labelStyle,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(64, 44),
          shape: AppRadius.smShape,
          textStyle: labelStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(64, 44),
          shape: AppRadius.smShape,
          side: AppNeo.side,
          textStyle: labelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          textStyle: labelStyle?.copyWith(
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: semantic.textSecondary,
        ),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: semantic.textSecondary,
        ),
        prefixStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        suffixStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        border: _outline(AppColors.ink),
        enabledBorder: _outline(AppColors.ink),
        focusedBorder: _outline(AppColors.ink, width: AppNeo.focusBorderWidth),
        errorBorder: _outline(semantic.danger),
        focusedErrorBorder: _outline(
          semantic.danger,
          width: AppNeo.focusBorderWidth,
        ),
        disabledBorder: _outline(AppColors.ink.withValues(alpha: 0.4)),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: semantic.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.ink,
        dragHandleSize: Size(48, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sm),
          ),
          side: AppNeo.side,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: AppRadius.smShape,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: AppRadius.smShape,
        textStyle: textTheme.bodyMedium,
      ),
      checkboxTheme: CheckboxThemeData(
        side: AppNeo.side,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surface,
        ),
        checkColor: WidgetStatePropertyAll(colors.onPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.surface,
        linearMinHeight: 12,
        borderRadius: BorderRadius.zero,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.ink,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: semantic.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.ink,
        thickness: AppNeo.borderWidth,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.ink,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.surface),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        elevation: 0,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.surface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.smAll,
          side: BorderSide(color: AppColors.yellow, width: AppNeo.borderWidth),
        ),
      ),
    );
  }

  /// Space Grotesk untuk heading (display/headline/title), Inter
  /// Medium/SemiBold untuk body & label.
  static TextTheme _textTheme(ColorScheme colors) {
    final base = ThemeData(brightness: colors.brightness).textTheme
        .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface);

    TextStyle grotesk(TextStyle? style, FontWeight weight) =>
        GoogleFonts.spaceGrotesk(textStyle: style, fontWeight: weight);
    TextStyle? inter(TextStyle? style, FontWeight weight) =>
        GoogleFonts.inter(textStyle: style, fontWeight: weight);

    return base.copyWith(
      displayLarge: grotesk(base.displayLarge, FontWeight.w700),
      displayMedium: grotesk(base.displayMedium, FontWeight.w700),
      displaySmall: grotesk(base.displaySmall, FontWeight.w700),
      // H1 — Sisa saldo harian.
      headlineLarge: grotesk(
        base.headlineLarge,
        FontWeight.w700,
      ).copyWith(fontSize: 36, letterSpacing: -1, height: 1.1),
      // H2 — Judul halaman.
      headlineMedium: grotesk(
        base.headlineMedium,
        FontWeight.w700,
      ).copyWith(fontSize: 26, letterSpacing: -0.5),
      headlineSmall: grotesk(base.headlineSmall, FontWeight.w700),
      titleLarge: grotesk(
        base.titleLarge,
        FontWeight.w700,
      ).copyWith(fontSize: 22, letterSpacing: -0.3),
      titleMedium: grotesk(
        base.titleMedium,
        FontWeight.w700,
      ).copyWith(fontSize: 17),
      titleSmall: grotesk(base.titleSmall, FontWeight.w700),
      bodyLarge: inter(base.bodyLarge, FontWeight.w500)?.copyWith(fontSize: 16),
      bodyMedium: inter(
        base.bodyMedium,
        FontWeight.w500,
      )?.copyWith(fontSize: 14),
      // Caption.
      bodySmall: inter(base.bodySmall, FontWeight.w500)?.copyWith(fontSize: 12),
      labelLarge: inter(base.labelLarge, FontWeight.w700),
      labelMedium: inter(base.labelMedium, FontWeight.w600),
      labelSmall: inter(base.labelSmall, FontWeight.w600),
    );
  }

  static OutlineInputBorder _outline(
    Color color, {
    double width = AppNeo.borderWidth,
  }) => OutlineInputBorder(
    borderRadius: AppRadius.smAll,
    borderSide: BorderSide(color: color, width: width),
  );
}
