import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

/// Database yang sudah terbuka. Wajib di-override di `main()` (dan di test).
final appDatabaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('Override appDatabaseProvider.'),
);
