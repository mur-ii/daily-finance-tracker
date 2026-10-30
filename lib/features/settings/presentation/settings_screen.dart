import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/reminder_service.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/danger_confirm_dialog.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/section_header.dart';
import '../../daily_tracking/presentation/providers.dart';
import '../data/reminder_prefs.dart';

/// Pengaturan pengingat harian dan pengelolaan data.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ReminderSettings? _reminder;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    loadReminderSettings().then((value) {
      if (mounted) setState(() => _reminder = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminder = _reminder;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SectionHeader('Pengingat'),
          NeoBox(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: reminder == null
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Pengingat harian'),
                        subtitle: const Text(
                          'Notifikasi untuk mencatat pengeluaran.',
                        ),
                        value: reminder.enabled,
                        onChanged: _busy ? null : _toggleReminder,
                      ),
                      ListTile(
                        enabled: reminder.enabled && !_busy,
                        leading: const Icon(Icons.schedule),
                        title: const Text('Jam pengingat'),
                        trailing: Text(
                          reminder.time.format(context),
                          style: context.textTheme.titleMedium,
                        ),
                        onTap: _pickTime,
                      ),
                    ],
                  ),
          ),
          const SectionHeader('Data'),
          NeoBox(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua data hanya tersimpan di perangkat ini. Menghapus '
                  'data tidak bisa dibatalkan.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.semanticColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: NeoButton(
                    color: context.semanticColors.danger,
                    foregroundColor: context.colors.surface,
                    onPressed: _busy ? null : _resetAll,
                    child: const Text('Hapus semua data'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReminder(bool enabled) async {
    final current = _reminder!;
    final service = ref.read(reminderServiceProvider);
    setState(() => _busy = true);
    try {
      if (enabled) {
        if (!await service.requestPermission()) {
          _showMessage('Izin notifikasi ditolak. Aktifkan di pengaturan HP.');
          return;
        }
        await service.scheduleDaily(current.time);
      } else {
        await service.cancel();
      }
      await _save(ReminderSettings(enabled: enabled, time: current.time));
    } catch (_) {
      _showMessage('Gagal mengatur pengingat.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickTime() async {
    final current = _reminder!;
    final picked = await showTimePicker(
      context: context,
      initialTime: current.time,
    );
    if (picked == null) return;
    try {
      await ref.read(reminderServiceProvider).scheduleDaily(picked);
      await _save(ReminderSettings(enabled: current.enabled, time: picked));
    } catch (_) {
      _showMessage('Gagal mengatur pengingat.');
    }
  }

  Future<void> _save(ReminderSettings settings) async {
    await saveReminderSettings(settings);
    if (mounted) setState(() => _reminder = settings);
  }

  Future<void> _resetAll() async {
    final confirmed = await showDangerConfirmDialog(
      context,
      title: 'Hapus semua data?',
      message:
          'Semua periode, pengeluaran wajib, transaksi, dan streak akan '
          'dihapus permanen.',
      confirmLabel: 'Hapus semua',
      typeToConfirm: 'HAPUS',
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    // Router otomatis mengarahkan ke halaman setup setelah data kosong.
    await ref.read(activePeriodProvider.notifier).resetAll();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
