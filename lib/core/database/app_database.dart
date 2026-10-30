import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract final class DbTables {
  static const budgetPeriod = 'budget_period';
  static const fixedExpense = 'fixed_expense';
  static const dailyTransaction = 'daily_transaction';
}

const int _schemaVersion = 1;

/// Membuka database aplikasi.
///
/// [path] dan [factory] bisa di-override untuk test (mis. in-memory).
/// Default: file `daily_tracking.db` di folder database bawaan platform.
Future<Database> openAppDatabase({
  String? path,
  DatabaseFactory? factory,
}) async {
  final dbFactory = factory ?? databaseFactory;
  final dbPath =
      path ?? p.join(await dbFactory.getDatabasesPath(), 'daily_tracking.db');

  return dbFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: _schemaVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    ),
  );
}

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE ${DbTables.budgetPeriod} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      total_income INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      days_count INTEGER NOT NULL CHECK (days_count > 0),
      is_active INTEGER NOT NULL DEFAULT 1
    )
  ''');
  // Hanya boleh ada satu periode aktif.
  await db.execute('''
    CREATE UNIQUE INDEX idx_budget_period_single_active
    ON ${DbTables.budgetPeriod} (is_active) WHERE is_active = 1
  ''');

  await db.execute('''
    CREATE TABLE ${DbTables.fixedExpense} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      period_id INTEGER NOT NULL
        REFERENCES ${DbTables.budgetPeriod}(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      amount INTEGER NOT NULL CHECK (amount >= 0)
    )
  ''');
  await db.execute('''
    CREATE INDEX idx_fixed_expense_period
    ON ${DbTables.fixedExpense} (period_id)
  ''');

  await db.execute('''
    CREATE TABLE ${DbTables.dailyTransaction} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      period_id INTEGER NOT NULL
        REFERENCES ${DbTables.budgetPeriod}(id) ON DELETE CASCADE,
      date TEXT NOT NULL,
      amount INTEGER NOT NULL CHECK (amount > 0),
      category TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT ''
    )
  ''');
  await db.execute('''
    CREATE INDEX idx_daily_transaction_period_date
    ON ${DbTables.dailyTransaction} (period_id, date)
  ''');
}
