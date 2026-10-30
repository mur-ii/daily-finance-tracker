import '../../../core/utils/date_utils.dart';
import 'entities.dart';

/// Transaksi hanya boleh dicatat pada tanggal di dalam periode.
bool isDateWithinPeriod(BudgetPeriod period, DateTime date) {
  final day = dateOnly(date);
  return !day.isBefore(dateOnly(period.startDate)) &&
      !day.isAfter(period.endDate);
}
