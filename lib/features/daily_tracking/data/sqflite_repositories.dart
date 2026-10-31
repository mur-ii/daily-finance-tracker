import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'mappers.dart';

class SqfliteBudgetPeriodRepository implements BudgetPeriodRepository {
  SqfliteBudgetPeriodRepository(this._db);

  final Database _db;

  @override
  Future<BudgetPeriod?> getActive() async {
    final rows = await _db.query(
      DbTables.budgetPeriod,
      where: 'is_active = 1',
      limit: 1,
    );
    return rows.isEmpty ? null : BudgetPeriodMapper.fromMap(rows.first);
  }

  @override
  Future<int> startNew(BudgetPeriod period) {
    return _db.transaction((txn) async {
      await txn.update(DbTables.budgetPeriod, {'is_active': 0});
      return txn.insert(DbTables.budgetPeriod, {
        ...period.toMap(),
        'id': null,
        'is_active': 1,
      });
    });
  }

  @override
  Future<List<BudgetPeriod>> listAll() async {
    final rows = await _db.query(
      DbTables.budgetPeriod,
      orderBy: 'start_date DESC, id DESC',
    );
    return rows.map(BudgetPeriodMapper.fromMap).toList();
  }

  @override
  Future<BudgetPeriod?> getById(int id) async {
    final rows = await _db.query(
      DbTables.budgetPeriod,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : BudgetPeriodMapper.fromMap(rows.first);
  }

  @override
  Future<void> delete(int id) async {
    // Tagihan & transaksi ikut terhapus lewat ON DELETE CASCADE.
    await _db.delete(
      DbTables.budgetPeriod,
      where: 'id = ? AND is_active = 0',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAll() {
    return _db.transaction((txn) async {
      await txn.delete(DbTables.dailyTransaction);
      await txn.delete(DbTables.fixedExpense);
      await txn.delete(DbTables.budgetPeriod);
    });
  }
}

class SqfliteFixedExpenseRepository implements FixedExpenseRepository {
  SqfliteFixedExpenseRepository(this._db);

  final Database _db;

  @override
  Future<List<FixedExpense>> listByPeriod(int periodId) async {
    final rows = await _db.query(
      DbTables.fixedExpense,
      where: 'period_id = ?',
      whereArgs: [periodId],
      orderBy: 'id ASC',
    );
    return rows.map(FixedExpenseMapper.fromMap).toList();
  }

  @override
  Future<int> add(FixedExpense expense) =>
      _db.insert(DbTables.fixedExpense, expense.toMap());

  @override
  Future<void> update(FixedExpense expense) async {
    await _db.update(
      DbTables.fixedExpense,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete(DbTables.fixedExpense, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> saveChanges({
    required List<FixedExpense> added,
    required List<FixedExpense> updated,
    required List<int> removedIds,
  }) {
    return _db.transaction((txn) async {
      for (final id in removedIds) {
        await txn.delete(
          DbTables.fixedExpense,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      for (final expense in updated) {
        await txn.update(
          DbTables.fixedExpense,
          expense.toMap(),
          where: 'id = ?',
          whereArgs: [expense.id],
        );
      }
      for (final expense in added) {
        await txn.insert(DbTables.fixedExpense, expense.toMap());
      }
    });
  }
}

class SqfliteDailyTransactionRepository implements DailyTransactionRepository {
  SqfliteDailyTransactionRepository(this._db);

  final Database _db;

  @override
  Future<List<DailyTransaction>> listByPeriod(int periodId) async {
    final rows = await _db.query(
      DbTables.dailyTransaction,
      where: 'period_id = ?',
      whereArgs: [periodId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(DailyTransactionMapper.fromMap).toList();
  }

  @override
  Future<List<DateTime>> listRecentDates({int limit = 400}) async {
    final rows = await _db.query(
      DbTables.dailyTransaction,
      columns: ['date'],
      distinct: true,
      orderBy: 'date DESC',
      limit: limit,
    );
    return [for (final r in rows) decodeDate(r['date'] as String)];
  }

  @override
  Future<int> add(DailyTransaction transaction) =>
      _db.insert(DbTables.dailyTransaction, transaction.toMap());

  @override
  Future<void> update(DailyTransaction transaction) async {
    await _db.update(
      DbTables.dailyTransaction,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete(
      DbTables.dailyTransaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
