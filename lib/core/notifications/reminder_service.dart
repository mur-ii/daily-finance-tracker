import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service pengingat harian. Di-override dengan fake di test.
final reminderServiceProvider = Provider<ReminderService>(
  (ref) => LocalReminderService(),
);

abstract interface class ReminderService {
  Future<void> init();

  /// Mengembalikan false bila user menolak izin notifikasi.
  Future<bool> requestPermission();

  /// Menjadwalkan (ulang) pengingat setiap hari pada [time].
  Future<void> scheduleDaily(TimeOfDay time);

  Future<void> cancel();
}

class LocalReminderService implements ReminderService {
  static const int _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> scheduleDaily(TimeOfDay time) async {
    await cancel();
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'Sudah catat pengeluaran hari ini?',
      body: 'Jaga streak-mu 🔥',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Pengingat harian',
          channelDescription: 'Pengingat untuk mencatat pengeluaran harian',
        ),
      ),
      // Inexact: tidak butuh izin exact alarm; telat beberapa menit tidak
      // masalah untuk pengingat.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() => _plugin.cancel(id: _notificationId);
}
