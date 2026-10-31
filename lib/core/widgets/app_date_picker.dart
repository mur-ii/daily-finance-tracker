import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import '../utils/date_utils.dart';
import 'neo_box.dart';

/// Lokalisasi Indonesia untuk kalender: minggu dimulai Senin, bawaannya Minggu.
class _MondayFirstLocalizations extends MaterialLocalizationId {
  _MondayFirstLocalizations()
    : super(
        fullYearFormat: DateFormat.y(appLocale),
        compactDateFormat: DateFormat.yMd(appLocale),
        shortDateFormat: DateFormat.yMMMd(appLocale),
        mediumDateFormat: DateFormat('EEE, MMM d', appLocale),
        longDateFormat: DateFormat.yMMMMEEEEd(appLocale),
        yearMonthFormat: DateFormat.yMMMM(appLocale),
        shortMonthDayFormat: DateFormat.MMMd(appLocale),
        decimalFormat: NumberFormat.decimalPattern(appLocale),
        twoDigitZeroPaddedFormat: NumberFormat('00', appLocale),
      );

  @override
  int get firstDayOfWeekIndex => 1;

  // Bawaannya satu huruf, sehingga Senin, Selasa, dan Sabtu sama-sama "S".
  @override
  List<String> get narrowWeekdays => const [
    'MIN',
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
  ];
}

class _MondayFirstDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MondayFirstDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture(_MondayFirstLocalizations());

  @override
  bool shouldReload(_MondayFirstDelegate old) => false;
}

/// Bottom sheet pemilih tanggal sesuai docs/04_design.md.
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
  // CalendarDatePicker mewajibkan tanggal awal berada di dalam rentang.
  late DateTime _selected = widget.initialDate.isBefore(widget.firstDate)
      ? widget.firstDate
      : widget.initialDate.isAfter(widget.lastDate)
      ? widget.lastDate
      : widget.initialDate;

  ThemeData _calendarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final text = context.textTheme;
    final secondary = context.semanticColors.textSecondary;

    WidgetStateProperty<Color?> foreground() =>
        WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.onPrimary;
          if (states.contains(WidgetState.disabled)) {
            return secondary.withValues(alpha: 0.4);
          }
          return AppColors.ink;
        });
    final background = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.selected) ? colors.primary : null,
    );
    const cellShape = WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: AppRadius.smAll),
    );

    return theme.copyWith(
      // Judul bulan pada header kalender memakai titleSmall.
      textTheme: text.copyWith(titleSmall: text.titleMedium),
      datePickerTheme: DatePickerThemeData(
        subHeaderForegroundColor: AppColors.ink,
        weekdayStyle: text.bodySmall?.copyWith(color: secondary),
        dayStyle: text.bodyMedium,
        dayShape: cellShape,
        dayForegroundColor: foreground(),
        dayBackgroundColor: background,
        todayForegroundColor: foreground(),
        todayBackgroundColor: background,
        todayBorder: const BorderSide(color: AppColors.ink),
        yearStyle: text.bodyMedium,
        yearShape: cellShape,
        yearForegroundColor: foreground(),
        yearBackgroundColor: background,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final semantic = context.semanticColors;

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
            child: Localizations.override(
              context: context,
              delegates: const [_MondayFirstDelegate()],
              child: Theme(
                data: _calendarTheme(context),
                child: CalendarDatePicker(
                  initialDate: _selected,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (value) => setState(() => _selected = value),
                ),
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
