import 'package:intl/intl.dart';

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// Mengambil angka dari input user (mis. "1.200.000" -> 1200000).
/// Null jika tidak ada digit atau terlalu besar.
int? parseRupiah(String? input) {
  final digits = (input ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? null : int.tryParse(digits);
}

/// Format nominal Rupiah (disimpan sebagai int) untuk ditampilkan di UI.
String formatRupiah(int amount) => _rupiah.format(amount);
