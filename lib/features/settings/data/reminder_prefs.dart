import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _reminderEnabledKey = 'reminder_enabled';
const String _reminderMinutesKey = 'reminder_minutes';

/// Jam pengingat default: 20:00.
const TimeOfDay defaultReminderTime = TimeOfDay(hour: 20, minute: 0);

class ReminderSettings {
  const ReminderSettings({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;
}

Future<ReminderSettings> loadReminderSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final minutes = prefs.getInt(_reminderMinutesKey);
  return ReminderSettings(
    enabled: prefs.getBool(_reminderEnabledKey) ?? false,
    time: minutes == null
        ? defaultReminderTime
        : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
  );
}

Future<void> saveReminderSettings(ReminderSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_reminderEnabledKey, settings.enabled);
  await prefs.setInt(
    _reminderMinutesKey,
    settings.time.hour * 60 + settings.time.minute,
  );
}
