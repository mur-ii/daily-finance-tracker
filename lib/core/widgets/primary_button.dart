import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import 'neo_box.dart';

/// Tombol aksi utama selebar parent: [NeoButton] hitam dengan teks putih tebal.
/// Saat [isLoading], tombol nonaktif dan menampilkan spinner.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: context.semanticColors.textSecondary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: NeoButton(
        onPressed: isLoading ? null : onPressed,
        child: Semantics(label: isLoading ? label : null, child: child),
      ),
    );
  }
}
