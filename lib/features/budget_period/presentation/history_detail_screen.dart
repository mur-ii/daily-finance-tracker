import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/danger_confirm_dialog.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../daily_tracking/presentation/category_labels.dart';
import '../../daily_tracking/presentation/providers.dart';
import 'history_screen.dart';

/// Detail satu periode; hanya baca (tanpa tambah/ubah/hapus).
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.periodId});

  final int periodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(periodDetailProvider(periodId));
    final data = detail.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Periode'),
        actions: [
          if (data != null && !data.period.isActive)
            IconButton(
              tooltip: 'Hapus periode',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: detail.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail.hasError
          ? Center(
              child: TextButton(
                onPressed: () => ref.invalidate(periodDetailProvider(periodId)),
                child: const Text('Gagal memuat data. Coba lagi'),
              ),
            )
          : data == null
          ? const Center(child: EmptyHint('Periode tidak ditemukan.'))
          : _Detail(data: data),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDangerConfirmDialog(
      context,
      title: 'Hapus periode ini?',
      message:
          'Pengeluaran wajib dan semua transaksi di periode ini ikut '
          'terhapus permanen.',
    );
    if (!confirmed) return;
    await ref.read(activePeriodProvider.notifier).deleteArchived(periodId);
    if (context.mounted) await Navigator.of(context).maybePop();
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final period = data.period;
    final summary = data.summary;
    final remaining = summary.netFunds - summary.totalSpent;
    final semantic = context.semanticColors;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        NeoBox(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatDate(period.startDate)} - '
                      '${formatDate(period.endDate)}',
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  if (period.isActive) const ActiveBadge(),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              DetailRow(
                label: 'Pemasukan',
                value: formatRupiah(period.totalIncome),
              ),
              DetailRow(
                label: 'Saldo bersih',
                value: formatRupiah(summary.netFunds),
              ),
              DetailRow(
                label: 'Jatah harian',
                value: formatRupiah(summary.dailyBase),
              ),
              DetailRow(
                label: 'Total pengeluaran',
                value: formatRupiah(summary.totalSpent),
              ),
              const Divider(height: AppSpacing.md),
              DetailRow(
                label: 'Sisa',
                value: formatRupiah(remaining),
                valueColor: remaining < 0 ? semantic.danger : semantic.success,
                emphasize: true,
              ),
            ],
          ),
        ),
        const SectionHeader('Pengeluaran wajib'),
        if (data.fixedExpenses.isEmpty)
          const EmptyHint('Tidak ada pengeluaran wajib.'),
        for (final e in data.fixedExpenses)
          TransactionListTile(
            icon: Icons.receipt_long_outlined,
            title: e.name,
            amount: e.amount,
          ),
        const SectionHeader('Transaksi'),
        if (data.transactions.isEmpty)
          const EmptyHint('Tidak ada pengeluaran tercatat.'),
        for (final t in data.transactions)
          TransactionListTile(
            icon: t.category.icon,
            title: t.category.label,
            subtitle: t.note.isEmpty
                ? formatDayMonth(t.date)
                : '${t.note} · ${formatDayMonth(t.date)}',
            amount: t.amount,
          ),
      ],
    );
  }
}
