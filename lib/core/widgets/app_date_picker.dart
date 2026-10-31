import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import '../utils/date_utils.dart';
import 'neo_box.dart';

/// Bottom sheet pemilih tanggal (Syncfusion) sesuai docs/04_design.md.
/// Mengembalikan `null` bila dibatalkan.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String title = 'Pilih tanggal',
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AppDatePickerSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      title: title,
    ),
  );
}

class _AppDatePickerSheet extends StatefulWidget {
  const _AppDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  @override
  State<_AppDatePickerSheet> createState() => _AppDatePickerSheetState();
}

class _AppDatePickerSheetState extends State<_AppDatePickerSheet> {
  late DateTime _selected = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final semantic = context.semanticColors;
    final selectedText = text.bodyMedium?.copyWith(
      color: colors.onPrimary,
      fontWeight: FontWeight.w700,
    );

    // useSafeArea tidak menghindari navigation bar bawah, jadi tambahkan manual.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatFullDate(_selected),
            style: text.bodyMedium?.copyWith(color: semantic.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          NeoBox(
            shadow: false,
            child: SizedBox(
              height: 340,
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.single,
                initialSelectedDate: widget.initialDate,
                initialDisplayDate: widget.initialDate,
                minDate: widget.firstDate,
                maxDate: widget.lastDate,
                showNavigationArrow: true,
                backgroundColor: Colors.transparent,
                headerHeight: 48,
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Colors.transparent,
                  textAlign: TextAlign.center,
                  textStyle: text.titleMedium,
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                  viewHeaderHeight: 32,
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: text.bodySmall?.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: text.bodyMedium,
                  todayTextStyle: text.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  disabledDatesTextStyle: text.bodyMedium?.copyWith(
                    color: semantic.textSecondary.withValues(alpha: 0.4),
                  ),
                ),
                yearCellStyle: DateRangePickerYearCellStyle(
                  textStyle: text.bodyMedium,
                  todayTextStyle: text.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  disabledDatesTextStyle: text.bodyMedium?.copyWith(
                    color: semantic.textSecondary.withValues(alpha: 0.4),
                  ),
                ),
                selectionShape: DateRangePickerSelectionShape.rectangle,
                selectionRadius: AppRadius.sm,
                selectionColor: colors.primary,
                selectionTextStyle: selectedText,
                todayHighlightColor: AppColors.ink,
                onSelectionChanged: (args) {
                  final value = args.value;
                  if (value is DateTime) setState(() => _selected = value);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: NeoButton(
                  color: colors.surface,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: NeoButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: const Text('Pilih'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Field tanggal read-only bergaya input neo-brutalism yang membuka
/// [showAppDatePicker] saat ditekan.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: value,
      firstDate: firstDate,
      lastDate: lastDate,
      title: label,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.smAll,
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.ink,
          ),
        ),
        child: Text(formatDate(value), style: context.textTheme.bodyLarge),
      ),
    );
  }
}
