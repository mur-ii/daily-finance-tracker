import 'package:flutter/material.dart';

/// Palet neo-brutalism dari docs/04_design.md.
abstract final class AppColors {
  // Core
  /// Wajib untuk semua border dan hard shadow.
  static const Color ink = Color(0xFF000000);
  static const Color surface = Color(0xFFFFFFFF);

  /// Latar utama aplikasi (kuning terang, solid).
  static const Color background = Color(0xFFFFDE00);

  // Accent — blok warna solid untuk tag status dan peringatan.
  static const Color yellow = Color(0xFFFFDE00);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);

  // Text — sekunder tetap gelap agar kontras terjaga.
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3F3F46);

  // Semantic
  static const Color success = green;
  static const Color warning = yellow;
  static const Color danger = red;

  static const Color disabled = Color(0xFFE4E4E7);
}
