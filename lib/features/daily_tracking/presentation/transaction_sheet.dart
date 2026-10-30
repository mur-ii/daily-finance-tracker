import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_date_picker.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/entities.dart';
import 'category_labels.dart';
import 'providers.dart';

/// Bottom sheet tambah/ubah transaksi.
Future<void> showTransactionSheet(
  BuildContext context, {
  required BudgetPeriod period,
  required DateTime today,
  DailyTransaction? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        TransactionSheet(period: period, today: today, existing: existing),
  );
}

class TransactionSheet extends ConsumerStatefulWidget {
  const TransactionSheet({
    super.key,
    required this.period,
    required this.today,
    this.existing,
  });

  final BudgetPeriod period;
  final DateTime today;
  final DailyTransaction? existing;

  @override
  ConsumerState<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends ConsumerState<TransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionCategory _category;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toString(),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _category = existing?.category ?? TransactionCategory.food;
    _date = existing?.date ?? _clampToPeriod(widget.today);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime _clampToPeriod(DateTime value) {
    final day = dateOnly(value);
    final start = dateOnly(widget.period.startDate);
    final end = widget.period.endDate;
    if (day.isBefore(start)) return start;
    if (day.isAfter(end)) return end;
    return day;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(transactionsProvider.notifier)
          .save(
            DailyTransaction(
              id: widget.existing?.id,
              periodId: widget.period.id!,
              date: _date,
              amount: parseRupiah(_amountController.text)!,
              category: _category,
              note: _noteController.text,
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        // Keyboard terbuka: viewInsets; tertutup: navigation bar (viewPadding).
        AppSpacing.md +
            math.max(
              MediaQuery.viewInsetsOf(context).bottom,
              MediaQuery.viewPaddingOf(context).bottom,
            ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Ubah pengeluaran' : 'Catat pengeluaran',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _amountController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: validateMoney,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownMenu<TransactionCategory>(
                initialSelection: _category,
                label: const Text('Kategori'),
                // Field dan menu sama lebar dengan field input lain.
                expandedInsets: EdgeInsets.zero,
                requestFocusOnTap: false,
                leadingIcon: Icon(_category.icon, color: AppColors.ink),
                menuStyle: MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    context.colors.surface,
                  ),
                  surfaceTintColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  elevation: const WidgetStatePropertyAll(0),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  ),
                  shape: const WidgetStatePropertyAll(AppRadius.smShape),
                ),
                dropdownMenuEntries: [
                  for (final c in TransactionCategory.values)
                    DropdownMenuEntry(
                      value: c,
                      label: c.label,
                      leadingIcon: Icon(c.icon, size: 20),
                    ),
                ],
                onSelected: (c) {
                  if (c != null) setState(() => _category = c);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppDateField(
                label: 'Tanggal',
                value: _date,
                firstDate: dateOnly(widget.period.startDate),
                lastDate: widget.period.endDate,
                onChanged: (d) => setState(() => _date = d),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Simpan',
                isLoading: _saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
