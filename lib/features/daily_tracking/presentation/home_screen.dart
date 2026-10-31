import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/hero_daily_limit_card.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_banner.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../domain/entities.dart';
import 'category_labels.dart';
import 'providers.dart';
import 'transaction_sheet.dart';

enum _MenuAction { fixedExpenses, history, newPeriod, settings, about }

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final data = dashboard.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Finance Tracker'),
        actions: [
          PopupMenuButton<_MenuAction>(
            onSelected: (action) => _onMenu(context, action),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _MenuAction.fixedExpenses,
                child: Text('Pengeluaran wajib'),
              ),
              PopupMenuItem(
                value: _MenuAction.history,
                child: Text('Riwayat periode'),
              ),
              PopupMenuItem(
                value: _MenuAction.newPeriod,
                child: Text('Mulai periode baru'),
              ),
              PopupMenuItem(
                value: _MenuAction.settings,
                child: Text('Pengaturan'),
              ),
              PopupMenuItem(
                value: _MenuAction.about,
                child: Text('Tentang aplikasi'),
              ),
            ],
          ),
        ],
      ),
      body: data != null
          ? _Dashboard(data: data)
          : dashboard.hasError
          ? Center(
              child: TextButton(
                onPressed: () => ref.invalidate(dashboardProvider),
                child: const Text('Gagal memuat data. Coba lagi'),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: data == null || data.summary.isPeriodEnded
          ? null
          : NeoFab(
              icon: Icons.add,
              tooltip: 'Catat pengeluaran',
              onPressed: () => showTransactionSheet(
                context,
                period: data.period,
                today: ref.read(todayProvider),
              ),
            ),
    );
  }

  Future<void> _onMenu(BuildContext context, _MenuAction action) async {
    switch (action) {
      case _MenuAction.fixedExpenses:
        context.go(setupPath);
      case _MenuAction.history:
        context.push(historyPath);
      case _MenuAction.newPeriod:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Mulai periode baru?'),
            content: const Text(
              'Periode saat ini akan diarsipkan dan tidak bisa diubah lagi. '
              'Anda masih bisa melihatnya di Riwayat periode.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Lanjut'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) context.go(newPeriodPath);
      case _MenuAction.settings:
        context.push(settingsPath);
      case _MenuAction.about:
        context.push(aboutPath);
    }
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = data.summary;
    final transactions = data.transactions;
    final today = dateOnly(ref.watch(todayProvider));
    final spentToday = transactions
        .where((t) => dateOnly(t.date) == today)
        .fold<int>(0, (sum, t) => sum + t.amount);
    // Rollover: dana yang tersedia di awal hari ini melebihi jatah flat.
    final rollover = summary.todayLimit + spentToday - summary.dailyBase;

    return ListView(
      // Ruang bawah agar item terakhir tidak tertutup FAB.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl * 3,
      ),
      children: [
        if (summary.isPeriodEnded)
          StatusBanner(
            icon: Icons.event_busy_outlined,
            color: context.semanticColors.warning,
            title: 'Periode ini sudah berakhir',
            message: 'Mulai periode baru untuk lanjut mencatat.',
            action: TextButton(
              onPressed: () => context.go(newPeriodPath),
              child: const Text('Mulai'),
            ),
          ),
        if (summary.isPeriodEnded) const SizedBox(height: AppSpacing.sm),
        _LimitCard(data: data, spentToday: spentToday),
        if (!summary.isPeriodEnded) const _StreakBanner(),
        if (!summary.isPeriodEnded && rollover > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          StatusBanner(
            icon: Icons.savings_outlined,
            color: context.semanticColors.success,
            title: 'Hemat ${formatRupiah(rollover)}',
            message: 'Sisa dari hari sebelumnya ditambahkan ke limit hari ini.',
          ),
        ],
        const SectionHeader('Transaksi'),
        if (transactions.isEmpty)
          const EmptyHint('Belum ada pengeluaran. Tekan + untuk mencatat.'),
        for (final t in transactions)
          TransactionListTile(
            icon: t.category.icon,
            title: t.category.label,
            subtitle: t.note.isEmpty
                ? formatDayMonth(t.date)
                : '${t.note} · ${formatDayMonth(t.date)}',
            amount: t.amount,
            onTap: () => showTransactionSheet(
              context,
              period: data.period,
              today: ref.read(todayProvider),
              existing: t,
            ),
            trailing: IconButton(
              tooltip: 'Hapus',
              icon: Icon(
                Icons.delete_outline,
                color: context.semanticColors.textSecondary,
              ),
              onPressed: () => _confirmDelete(context, ref, t),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DailyTransaction t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus pengeluaran?'),
        content: Text(formatRupiah(t.amount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.semanticColors.danger,
              foregroundColor: context.colors.surface,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(transactionsProvider.notifier).remove(t.id!);
    }
  }
}

/// Streak pencatatan; menawarkan tanda "tidak jajan" bila hari ini kosong.
class _StreakBanner extends ConsumerWidget {
  const _StreakBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).value;
    if (streak == null) return const SizedBox.shrink();

    final title = streak.days == 0
        ? 'Mulai streak hari ini'
        : '🔥 ${streak.days} hari berturut-turut mencatat';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: StatusBanner(
        icon: Icons.local_fire_department_outlined,
        color: context.semanticColors.highlight,
        title: title,
        message: streak.recordedToday
            ? 'Hari ini sudah tercatat. Pertahankan!'
            : 'Catat pengeluaran atau tandai hari tanpa jajan.',
        action: streak.recordedToday
            ? null
            : TextButton(
                onPressed: () =>
                    ref.read(noSpendDaysProvider.notifier).markToday(),
                child: const Text('Tidak jajan'),
              ),
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.data, required this.spentToday});

  final DashboardData data;
  final int spentToday;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;

    // Progress = porsi dana hari ini yang sudah terpakai. Setelah periode
    // berakhir, tampilkan pemakaian sepanjang periode.
    final (spent, available) = summary.isPeriodEnded
        ? (summary.totalSpent, summary.accumulatedAllowance)
        : (spentToday, summary.todayLimit + spentToday);
    final spentRatio = available <= 0 ? 1.0 : spent / available;

    return HeroDailyLimitCard(
      remaining: summary.todayLimit,
      spentRatio: spentRatio,
      label: summary.isPeriodEnded
          ? 'Sisa akhir periode'
          : 'Limit jajan hari ini',
      footer: [
        HeroLimitDetailRow(
          label: 'Hari ke',
          value: '${summary.dayNumber} / ${data.period.daysCount}',
        ),
        HeroLimitDetailRow(
          label: 'Jatah harian',
          value: formatRupiah(summary.dailyBase),
        ),
        if (!summary.isPeriodEnded)
          HeroLimitDetailRow(
            label: 'Terpakai hari ini',
            value: formatRupiah(spentToday),
          ),
        HeroLimitDetailRow(
          label: 'Total pengeluaran',
          value: formatRupiah(summary.totalSpent),
        ),
        if (summary.tomorrowLimit != null)
          HeroLimitDetailRow(
            label: 'Limit besok (proyeksi)',
            value: formatRupiah(summary.tomorrowLimit!),
          ),
      ],
    );
  }
}
