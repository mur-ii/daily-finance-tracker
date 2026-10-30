import 'package:daily_tracking/core/utils/money.dart';
import 'package:daily_tracking/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseRupiah mengabaikan pemisah ribuan', () {
    expect(parseRupiah('1.200.000'), 1200000);
    expect(parseRupiah(''), isNull);
    expect(parseRupiah(null), isNull);
  });

  test('validateMoney', () {
    expect(validateMoney(''), isNotNull);
    expect(validateMoney('0'), isNotNull);
    expect(validateMoney('1000'), isNull);
    expect(validateMoney('9' * 15), isNotNull);
  });

  test('validateDays', () {
    expect(validateDays(''), isNotNull);
    expect(validateDays('0'), isNotNull);
    expect(validateDays('367'), isNotNull);
    expect(validateDays('30'), isNull);
  });

  test('validateName', () {
    expect(validateName('  '), isNotNull);
    expect(validateName('Kos'), isNull);
  });
}
