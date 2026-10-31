import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import '../utils/money.dart';
import 'neo_box.dart';

/// Item histori transaksi: ikon kategori, judul + subjudul, dan nominal.
/// Pengeluaran ditampilkan merah dengan tanda minus; pemasukan hijau.
///
/// Sengaja tidak bergantung pada entity fitur — kirim [icon] dan [title] dari
/// layar pemanggil (mis. `category.icon`, `category.label`).
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Nominal positif dalam Rupiah; ditampilkan dengan tanda minus.
  final int amount;
  final VoidCallback? onTap;

  /// Aksi tambahan di paling kanan, mis. tombol hapus.
  final Widget? trailing;

  /// Sorot dengan latar kuning, mis. item yang sedang diedit.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semanticColors;
    final textTheme = context.textTheme;

    return NeoBox(
      color: selected ? semantic.highlight : colors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm + 4,
        AppSpacing.sm + 4,
        trailing == null ? AppSpacing.md : AppSpacing.xs,
        AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: AppRadius.smAll,
              border: AppNeo.border,
            ),
            child: Icon(icon, size: 20, color: AppColors.ink),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: semantic.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '-${formatRupiah(amount)}',
            style: textTheme.bodyMedium?.copyWith(
              color: semantic.danger,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
