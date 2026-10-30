import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Dialog konfirmasi untuk aksi destruktif (tombol merah). Jika
/// [typeToConfirm] diisi, tombol baru aktif setelah user mengetik teks itu.
Future<bool> showDangerConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
  String? typeToConfirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _DangerConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      typeToConfirm: typeToConfirm,
    ),
  );
  return confirmed ?? false;
}

class _DangerConfirmDialog extends StatefulWidget {
  const _DangerConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.typeToConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String? typeToConfirm;

  @override
  State<_DangerConfirmDialog> createState() => _DangerConfirmDialogState();
}

class _DangerConfirmDialogState extends State<_DangerConfirmDialog> {
  String _typed = '';

  @override
  Widget build(BuildContext context) {
    final required = widget.typeToConfirm;
    final canConfirm = required == null || _typed.trim() == required;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          if (required != null) ...[
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: 'Ketik $required'),
              onChanged: (value) => setState(() => _typed = value),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.semanticColors.danger,
            foregroundColor: context.colors.surface,
          ),
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
