import 'money.dart';

const int maxMoney = 1000000000000;
const int maxPeriodDays = 366;

/// Validator form: mengembalikan pesan error, atau null jika valid.
String? validateMoney(String? value) {
  final amount = parseRupiah(value);
  if (amount == null) return 'Masukkan nominal';
  if (amount <= 0) return 'Nominal harus lebih dari 0';
  if (amount > maxMoney) return 'Nominal terlalu besar';
  return null;
}

String? validateDays(String? value) {
  final days = int.tryParse((value ?? '').trim());
  if (days == null) return 'Masukkan jumlah hari';
  if (days < 1 || days > maxPeriodDays) {
    return 'Jumlah hari harus 1-$maxPeriodDays';
  }
  return null;
}

String? validateName(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Masukkan nama';
  return null;
}
