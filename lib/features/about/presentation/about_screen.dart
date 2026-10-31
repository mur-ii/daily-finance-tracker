import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/neo_background.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/section_header.dart';

const String _appName = 'Daily Finance Tracker';
const String _saweriaUrl = 'https://saweria.co/murii';
const String _instagramUrl = 'https://instagram.com/murii.me';
const String _githubUrl = 'https://github.com/mur-ii';
const String _websiteUrl = 'https://sadri.my.id';

const List<(IconData, String)> _features = [
  (Icons.today_outlined, 'Limit belanja harian yang dihitung otomatis'),
  (Icons.receipt_long_outlined, 'Pencatatan transaksi per kategori'),
  (Icons.history, 'Riwayat periode anggaran'),
  (Icons.notifications_outlined, 'Pengingat harian untuk mencatat'),
];

/// Informasi aplikasi beserta profil singkat pengembangnya.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      // Versi hanya informasi tambahan: halaman tetap tampil tanpanya.
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final secondary = context.semanticColors.textSecondary;
    final version = _version;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: NeoBox(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Image.asset(
                'assets/images/logo_app.png',
                width: 88,
                height: 88,
                fit: BoxFit.contain,
                semanticLabel: 'Logo aplikasi',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _appName,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          if (version != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Versi $version',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: secondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Pencatat keuangan harian yang menunjukkan berapa yang aman '
            'dibelanjakan hari ini sampai gajian berikutnya.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SectionHeader('Fitur'),
          NeoBox(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                for (final (index, (icon, label)) in _features.indexed)
                  Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0 : AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(label, style: textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader('Privasi'),
          NeoBox(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Semua data hanya tersimpan di perangkat ini dan tidak memerlukan '
              'akun.',
              style: textTheme.bodyMedium,
            ),
          ),
          const SectionHeader('Pengembang'),
          NeoBox(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.smAll,
                      child: Image.asset(
                        'assets/images/profile.jpg',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        semanticLabel: 'Foto Muhammad Sadri',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Muhammad Sadri', style: textTheme.titleMedium),
                          Text(
                            'Software Developer',
                            style: textTheme.bodySmall?.copyWith(
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _SocialButton(
                      tooltip: 'Instagram @murii.me',
                      icon: FontAwesomeIcons.instagram,
                      onPressed: () => _openUrl(_instagramUrl),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _SocialButton(
                      tooltip: 'GitHub mur-ii',
                      icon: FontAwesomeIcons.github,
                      onPressed: () => _openUrl(_githubUrl),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _SocialButton(
                      tooltip: 'Website sadri.my.id',
                      icon: FontAwesomeIcons.globe,
                      onPressed: () => _openUrl(_websiteUrl),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _SocialButton(
                      tooltip: 'Dukung lewat Saweria',
                      icon: FontAwesomeIcons.mugHot,
                      onPressed: () => _openUrl(_saweriaUrl),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: _openLicenses,
              child: const Text('Lisensi open source'),
            ),
          ),
        ],
      ),
    );
  }

  void _openLicenses() {
    final version = _version;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Scaffold tema transparan, jadi halaman lisensi perlu latar sendiri.
        builder: (_) => NeoBackground(
          child: LicensePage(
            applicationName: _appName,
            applicationVersion: version == null ? null : 'Versi $version',
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan')),
      );
    }
  }
}

/// Tombol kotak ikon media sosial.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final FaIconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 44,
      child: NeoButton(
        color: context.colors.surface,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        minHeight: 44,
        onPressed: onPressed,
        child: FaIcon(icon, size: 18),
      ),
    );
  }
}
