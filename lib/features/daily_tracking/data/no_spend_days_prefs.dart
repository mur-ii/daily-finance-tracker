import 'package:shared_preferences/shared_preferences.dart';

import 'mappers.dart';

const String _noSpendDaysKey = 'no_spend_days';

/// Batas entri yang disimpan; cukup untuk menghitung streak ~1 tahun.
const int _maxEntries = 400;

/// Hari yang ditandai user sebagai "tidak jajan", agar streak tidak putus.
Future<List<DateTime>> loadNoSpendDays() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(_noSpendDaysKey) ?? const [];
  return raw.map(decodeDate).toList();
}

Future<void> markNoSpendDay(DateTime day) async {
  final prefs = await SharedPreferences.getInstance();
  final raw =
      {...?prefs.getStringList(_noSpendDaysKey), encodeDate(day)}.toList()
        // Format yyyy-MM-dd bisa diurutkan sebagai string.
        ..sort((a, b) => b.compareTo(a));
  await prefs.setStringList(_noSpendDaysKey, raw.take(_maxEntries).toList());
}

Future<void> clearNoSpendDays() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_noSpendDaysKey);
}
