import 'package:daily_tracking/features/daily_tracking/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 29, 14, 25);

  test('kosong = 0', () {
    expect(StreakCalculator.calculate([], today), 0);
  });

  test('hanya hari ini = 1', () {
    expect(StreakCalculator.calculate([DateTime(2026, 10, 29)], today), 1);
  });

  test('hari berturut-turut dihitung, duplikat diabaikan', () {
    final days = [
      DateTime(2026, 10, 29, 8),
      DateTime(2026, 10, 29, 20),
      DateTime(2026, 10, 28),
      DateTime(2026, 10, 27),
    ];
    expect(StreakCalculator.calculate(days, today), 3);
  });

  test('celah satu hari memutus streak', () {
    final days = [
      DateTime(2026, 10, 29),
      DateTime(2026, 10, 28),
      DateTime(2026, 10, 26),
    ];
    expect(StreakCalculator.calculate(days, today), 2);
  });

  test('hari ini belum tercatat: streak dihitung dari kemarin', () {
    final days = [DateTime(2026, 10, 28), DateTime(2026, 10, 27)];
    expect(StreakCalculator.calculate(days, today), 2);
  });

  test('terakhir tercatat dua hari lalu = 0', () {
    expect(StreakCalculator.calculate([DateTime(2026, 10, 27)], today), 0);
  });

  test('melewati pergantian bulan', () {
    final days = [
      DateTime(2026, 11, 1),
      DateTime(2026, 10, 31),
      DateTime(2026, 10, 30),
    ];
    expect(StreakCalculator.calculate(days, DateTime(2026, 11, 1)), 3);
  });
}
