import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/notifications/reminder_service.dart';
import 'features/settings/data/reminder_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Font dibaca dari assets/google_fonts/, bukan diunduh saat runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  _registerFontLicenses();
  final db = await openAppDatabase();
  final reminder = LocalReminderService();
  await _initReminder(reminder);

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        reminderServiceProvider.overrideWithValue(reminder),
      ],
      child: const App(),
    ),
  );
}

/// Lisensi OFL font yang di-bundel, tampil di halaman lisensi Flutter.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in const [
      ('Inter', 'OFL-Inter.txt'),
      ('Space Grotesk', 'OFL-SpaceGrotesk.txt'),
    ]) {
      final text = await rootBundle.loadString('assets/google_fonts/$file');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}

/// Pengingat bukan fitur inti: kegagalan di sini tidak boleh menahan app.
Future<void> _initReminder(ReminderService reminder) async {
  try {
    await reminder.init();
    final settings = await loadReminderSettings();
    if (settings.enabled) await reminder.scheduleDaily(settings.time);
  } catch (e) {
    debugPrint('Gagal menyiapkan pengingat: $e');
  }
}
