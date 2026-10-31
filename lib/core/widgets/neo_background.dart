import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Latar kuning solid di belakang setiap halaman. Scaffold di dalamnya
/// transparan (lihat `AppTheme`), jadi bungkus tiap halaman di router agar
/// transisi antarhalaman tetap tertutup penuh.
///
/// Konten halaman dijaga di atas navigation bar, sedangkan latarnya tetap
/// penuh sampai tepi layar. Bagian atas ditangani AppBar.
class NeoBackground extends StatelessWidget {
  const NeoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(top: false, child: child),
    );
  }
}
