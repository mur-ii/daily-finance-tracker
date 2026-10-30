import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/neo_box.dart';
import '../../../core/widgets/primary_button.dart';

const String _saweriaUrl = 'https://saweria.co/murii';
const String _instagramUrl = 'https://instagram.com/murii.me';
const String _githubUrl = 'https://github.com/mur-ii';
const String _websiteUrl = 'https://sadri.my.id';

/// Profil singkat pengembang aplikasi.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final secondary = context.semanticColors.textSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Pengembang')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: NeoBox(
              child: ClipRRect(
                borderRadius: AppRadius.smAll,
                child: Image.asset(
                  'assets/images/profile.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Muhammad Sadri',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Software Developer',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: secondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialButton(
                tooltip: 'Instagram @murii.me',
                icon: FontAwesomeIcons.instagram,
                onPressed: () => _openUrl(context, _instagramUrl),
              ),
              const SizedBox(width: AppSpacing.md),
              _SocialButton(
                tooltip: 'GitHub mur-ii',
                icon: FontAwesomeIcons.github,
                onPressed: () => _openUrl(context, _githubUrl),
              ),
              const SizedBox(width: AppSpacing.md),
              _SocialButton(
                tooltip: 'Website sadri.my.id',
                icon: FontAwesomeIcons.globe,
                onPressed: () => _openUrl(context, _websiteUrl),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Terima kasih sudah menggunakan Daily Finance Tracker! '
            'Semoga aplikasi ini membantu mengatur keuangan harian Anda.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Traktir Developer',
            icon: Icons.coffee,
            onPressed: () => _openUrl(context, _saweriaUrl),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
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
      dimension: 48,
      child: NeoButton(
        color: context.colors.surface,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: FaIcon(icon, size: 20),
      ),
    );
  }
}
