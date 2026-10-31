import 'dart:async';

import 'package:daily_tracking/core/utils/date_utils.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Dijalankan `flutter test` sebelum setiap file test; menyamakan `main`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await initializeDateFormatting(appLocale);
  await testMain();
}
