import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_date_picker.dart';
import '../../../core/widgets/primary_button.dart';
import '../../daily_tracking/presentation/providers.dart';

/// Form saldo awal + durasi + tanggal mulai.
class PeriodForm extends ConsumerStatefulWidget {
  const PeriodForm({super.key, this.isNewPeriod = false, this.onSaved});

  /// Jika true, tampilkan opsi menyalin pengeluaran wajib periode lama.
  final bool isNewPeriod;
  final VoidCallback? onSaved;

  @override
  ConsumerState<PeriodForm> createState() => _PeriodFormState();
}

class _PeriodFormState extends ConsumerState<PeriodForm> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _daysController = TextEditingController(text: '30');
  late DateTime _startDate = ref.read(todayProvider);
  bool _carryOver = true;
  bool _saving = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(activePeriodProvider.notifier)
          .startNew(
            totalIncome: parseRupiah(_incomeController.text)!,
            startDate: _startDate,
            daysCount: int.parse(_daysController.text.trim()),
            carryOverFixedExpenses: widget.isNewPeriod && _carryOver,
          );
      widget.onSaved?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan periode')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            widget.isNewPeriod ? 'Periode gajian baru' : 'Mulai periode gajian',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Masukkan gaji dan lama periode. Jatah harian dihitung otomatis.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.semanticColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _incomeController,
            decoration: const InputDecoration(
              labelText: 'Saldo awal / gaji',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: validateMoney,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _daysController,
            decoration: const InputDecoration(
              labelText: 'Jumlah hari menuju gajian berikutnya',
              suffixText: 'hari',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: validateDays,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDateField(
            label: 'Tanggal mulai',
            value: _startDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            onChanged: (d) => setState(() => _startDate = d),
          ),
          if (widget.isNewPeriod) ...[
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _carryOver,
              onChanged: (v) => setState(() => _carryOver = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Salin pengeluaran wajib periode sebelumnya'),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Simpan periode',
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
