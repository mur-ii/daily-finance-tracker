import 'package:daily_tracking/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime(2026, 10, 31);

  test('formatDate memakai nama bulan Indonesia', () {
    expect(formatDate(date), '31 Oktober 2026');
  });

  test('formatDayMonth tanpa tahun', () {
    expect(formatDayMonth(date), '31 Oktober');
  });

  test('formatFullDate dengan nama hari', () {
    expect(formatFullDate(date), 'Sabtu, 31 Oktober 2026');
  });
}
