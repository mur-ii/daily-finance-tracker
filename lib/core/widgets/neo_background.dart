import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Latar kuning solid di belakang setiap halaman. Scaffold di dalamnya
/// transparan (lihat `AppTheme`), jadi bungkus tiap halaman di router agar
/// transisi antarhalaman tetap tertutup penuh.
class NeoBackground extends StatelessWidget {
  const NeoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.background, child: child);
  }
}
