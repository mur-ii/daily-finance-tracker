import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_banner.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../daily_tracking/domain/budget_calculator.dart';
import '../../daily_tracking/domain/entities.dart';
import '../../daily_tracking/presentation/providers.dart';
import 'period_form.dart';

/// Setup: saldo awal + durasi, lalu daftar pengeluaran wajib.
class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(activePeriodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Anggaran')),
      body: period.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gagal memuat data'),
              TextButton(
                onPressed: () => ref.invalidate(activePeriodProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (period) => period == null
            ? const PeriodForm()
            : _FixedExpenseSection(period: period),
      ),
    );
  }
}

class _FixedExpenseSection extends ConsumerStatefulWidget {
  const _FixedExpenseSection({required this.period});

  final BudgetPeriod period;

  @override
  ConsumerState<_FixedExpenseSection> createState() =>
      _FixedExpenseSectionState();
}

class _FixedExpenseSectionState extends ConsumerState<_FixedExpenseSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  FixedExpense? _editing;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _startEdit(FixedExpense item) {
    setState(() => _editing = item);
    _nameController.text = item.name;
    _amountController.text = item.amount.toString();
  }

  void _resetForm() {
    setState(() => _editing = null);
    _nameController.clear();
    _amountController.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(fixedExpensesProvider.notifier);
    final amount = parseRupiah(_amountController.text)!;
    final editing = _editing;
    if (editing == null) {
      await notifier.add(name: _nameController.text, amount: amount);
    } else {
      await notifier.edit(editing, name: _nameController.text, amount: amount);
    }
    if (mounted) _resetForm();
  }

  Future<void> _remove(FixedExpense item) async {
    await ref.read(fixedExpensesProvider.notifier).remove(item.id!);
    if (_editing?.id == item.id && mounted) _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(fixedExpensesProvider);

    return expenses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(fixedExpensesProvider),
          child: const Text('Gagal memuat. Coba lagi'),
        ),
      ),
      data: (items) {
        final summary = BudgetCalculator.calculate(
          period: widget.period,
          fixedExpenses: items,
          transactions: const [],
          today: ref.read(todayProvider),
        );
        final canContinue = summary.netFunds > 0;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _SummaryCard(period: widget.period, summary: summary),
            const SectionHeader('Pengeluaran wajib'),
            if (items.isEmpty) const EmptyHint('Belum ada pengeluaran wajib.'),
            for (final item in items)
              TransactionListTile(
                icon: Icons.receipt_long_outlined,
                title: item.name,
                subtitle: 'Ketuk untuk mengubah',
                amount: item.amount,
                selected: _editing?.id == item.id,
                onTap: () => _startEdit(item),
                trailing: IconButton(
                  tooltip: 'Hapus ${item.name}',
                  icon: Icon(
                    Icons.delete_outline,
                    color: context.semanticColors.textSecondary,
                  ),
                  onPressed: () => _remove(item),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama tagihan (mis. Bayar Kos)',
                    ),
                    validator: validateName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: validateMoney,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: NeoButton(
                          color: context.colors.surface,
                          onPressed: _submit,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_editing == null ? Icons.add : Icons.check),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _editing == null
                                    ? 'Tambah tagihan'
                                    : 'Simpan perubahan',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_editing != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Batal'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!canContinue) ...[
              StatusBanner(
                icon: Icons.error_outline,
                color: context.semanticColors.danger,
                title: 'Sisa dana bersih harus lebih dari 0',
                message: 'Kurangi tagihan atau naikkan saldo awal.',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            PrimaryButton(
              label: 'Selesai',
              onPressed: canContinue ? () => context.go(homePath) : null,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.period, required this.summary});

  final BudgetPeriod period;
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalFixed = period.totalIncome - summary.netFunds;
    return NeoBox(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            label: 'Saldo awal',
            value: formatRupiah(period.totalIncome),
          ),
          DetailRow(
            label: 'Total pengeluaran wajib',
            value: formatRupiah(totalFixed),
          ),
          DetailRow(label: 'Durasi', value: '${period.daysCount} hari'),
          const Divider(height: AppSpacing.md),
          DetailRow(
            label: 'Sisa dana bersih',
            value: formatRupiah(summary.netFunds),
            emphasize: true,
          ),
          DetailRow(
            label: 'Jatah harian',
            value: formatRupiah(summary.dailyBase),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}
