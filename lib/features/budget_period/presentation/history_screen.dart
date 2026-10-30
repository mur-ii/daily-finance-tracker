import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/section_header.dart';
import '../../daily_tracking/presentation/providers.dart';

/// Daftar semua periode (aktif dan arsip), terbaru di atas.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(periodHistoryProvider);
    final items = history.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Periode')),
      body: items != null
          ? items.isEmpty
                ? const Center(child: EmptyHint('Belum ada riwayat.'))
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      for (final item in items) _PeriodCard(data: item),
                    ],
                  )
          : history.hasError
          ? Center(
              child: TextButton(
                onPressed: () => ref.invalidate(periodHistoryProvider),
                child: const Text('Gagal memuat data. Coba lagi'),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final period = data.period;
    final summary = data.summary;
    final fmt = DateFormat.yMMMd();
    final remaining = summary.netFunds - summary.totalSpent;
    final semantic = context.semanticColors;

    return NeoBox(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => context.push(historyDetailPath(period.id!)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${fmt.format(period.startDate)} - '
                  '${fmt.format(period.endDate)}',
                  style: context.textTheme.titleMedium,
                ),
              ),
              if (period.isActive) const ActiveBadge(),
              const Icon(Icons.chevron_right, color: AppColors.ink),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DetailRow(
            label: 'Pemasukan',
            value: formatRupiah(period.totalIncome),
          ),
          DetailRow(
            label: 'Total pengeluaran',
            value: formatRupiah(summary.totalSpent),
          ),
          DetailRow(
            label: 'Sisa',
            value: formatRupiah(remaining),
            valueColor: remaining < 0 ? semantic.danger : semantic.success,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

/// Label kecil penanda periode aktif.
class ActiveBadge extends StatelessWidget {
  const ActiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.semanticColors.highlight,
        borderRadius: AppRadius.smAll,
        border: AppNeo.border,
      ),
      child: Text(
        'Aktif',
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
