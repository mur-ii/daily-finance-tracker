import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Kontainer neo-brutalism: border hitam 2px, sudut 4px, dan hard shadow
/// 4px ke kanan-bawah. Bila [onTap] diisi, saat ditekan shadow hilang dan
/// kotak turun 4px.
class NeoBox extends StatefulWidget {
  const NeoBox({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.shadow = true,
  });

  final Widget child;

  /// Default: `colorScheme.surface` (putih).
  final Color? color;
  final EdgeInsetsGeometry? padding;

  /// Jarak di luar kotak; sisakan ruang untuk hard shadow.
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool shadow;

  @override
  State<NeoBox> createState() => _NeoBoxState();
}

class _NeoBoxState extends State<NeoBox> {
  bool _pressed = false;

  @override
  void didUpdateWidget(NeoBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap == null) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final pressed = widget.onTap != null && _pressed;
    final offset = pressed ? AppNeo.shadowOffset : Offset.zero;

    Widget content = widget.padding == null
        ? widget.child
        : Padding(padding: widget.padding!, child: widget.child);
    if (widget.onTap != null) {
      content = InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: AppColors.ink.withValues(alpha: 0.04),
        borderRadius: AppRadius.smAll,
        child: content,
      );
    }

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
        decoration: BoxDecoration(
          color: widget.color ?? context.colors.surface,
          borderRadius: AppRadius.smAll,
          border: AppNeo.border,
          boxShadow: widget.shadow && !pressed ? AppNeo.shadow : const [],
        ),
        child: Material(type: MaterialType.transparency, child: content),
      ),
    );
  }
}

/// Tombol neo-brutalism di atas [NeoBox]. Default hitam pekat dengan teks
/// putih tebal; nonaktif (abu-abu, tanpa shadow) bila [onPressed] null.
class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.foregroundColor,
    this.minHeight = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;

  /// Default: `colorScheme.primary` (hitam).
  final Color? color;

  /// Default: `colorScheme.onPrimary` (putih) bila [color] tidak diisi,
  /// selain itu hitam.
  final Color? foregroundColor;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = enabled
        ? foregroundColor ??
              (color == null ? context.colors.onPrimary : AppColors.ink)
        : context.semanticColors.textSecondary;

    Widget button = Semantics(
      button: true,
      enabled: enabled,
      child: NeoBox(
        color: enabled ? color ?? context.colors.primary : AppColors.disabled,
        shadow: enabled,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight - 2 * AppNeo.borderWidth,
          ),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1,
              child: DefaultTextStyle.merge(
                style: context.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: foreground, size: 20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) button = Tooltip(message: tooltip, child: button);
    return button;
  }
}

/// Floating action button kotak bergaya [NeoButton].
class NeoFab extends StatelessWidget {
  const NeoFab({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 60,
      child: NeoButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        child: Icon(icon, size: 30),
      ),
    );
  }
}
