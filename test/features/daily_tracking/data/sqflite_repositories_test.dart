import 'package:daily_tracking/core/database/app_database.dart';
import 'package:daily_tracking/features/daily_tracking/data/sqflite_repositories.dart';
import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SqfliteBudgetPeriodRepository periods;
  late SqfliteFixedExpenseRepository fixed;
  late SqfliteDailyTransactionRepository transactions;

  BudgetPeriod newPeriod({int income = 3000000}) => BudgetPeriod(
    totalIncome: income,
    startDate: DateTime(2026, 10, 1),
    daysCount: 30,
  );

  setUp(() async {
    db = await openAppDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    periods = SqfliteBudgetPeriodRepository(db);
    fixed = SqfliteFixedExpenseRepository(db);
    transactions = SqfliteDailyTransactionRepository(db);
  });

  tearDown(() => db.close());

  group('BudgetPeriodRepository', () {
    test('getActive null saat belum ada periode', () async {
      expect(await periods.getActive(), isNull);
    });

    test('startNew menyimpan dan membaca kembali periode', () async {
      final id = await periods.startNew(newPeriod());
      final active = await periods.getActive();
      expect(active?.id, id);
      expect(active?.totalIncome, 3000000);
      expect(active?.startDate, DateTime(2026, 10, 1));
      expect(active?.daysCount, 30);
      expect(active?.isActive, isTrue);
    });

    test('startNew menonaktifkan periode sebelumnya', () async {
      final first = await periods.startNew(newPeriod());
      final second = await periods.startNew(newPeriod(income: 5000000));
      expect((await periods.getActive())?.id, second);
      final rows = await db.query(
        DbTables.budgetPeriod,
        where: 'id = ?',
        whereArgs: [first],
      );
      expect(rows.single['is_active'], 0);
    });

    test(
      'listAll mengurutkan terbaru dulu dan getById membaca periode',
      () async {
        final first = await periods.startNew(newPeriod());
        final second = await periods.startNew(newPeriod(income: 5000000));

        final all = await periods.listAll();
        expect(all.map((p) => p.id), [second, first]);
        expect(all.last.isActive, isFalse);

        expect((await periods.getById(first))?.totalIncome, 3000000);
        expect(await periods.getById(999), isNull);
      },
    );

    test('daysCount <= 0 ditolak oleh constraint DB', () async {
      final bad = BudgetPeriod(
        totalIncome: 1000,
        startDate: DateTime(2026, 10, 1),
        daysCount: 0,
      );
      expect(periods.startNew(bad), throwsA(isA<DatabaseException>()));
    });
  });

  group('FixedExpenseRepository', () {
    late int periodId;
    setUp(() async => periodId = await periods.startNew(newPeriod()));

    test('add, list, update, delete', () async {
      final id = await fixed.add(
        FixedExpense(periodId: periodId, name: 'Kos', amount: 1000000),
      );
      var list = await fixed.listByPeriod(periodId);
      expect(list.single.name, 'Kos');

      await fixed.update(
        FixedExpense(id: id, periodId: periodId, name: 'Kos', amount: 1200000),
      );
      list = await fixed.listByPeriod(periodId);
      expect(list.single.amount, 1200000);

      await fixed.delete(id);
      expect(await fixed.listByPeriod(periodId), isEmpty);
    });

    test('foreign key menolak periodId yang tidak ada', () async {
      expect(
        fixed.add(const FixedExpense(periodId: 999, name: 'X', amount: 1)),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('DailyTransactionRepository', () {
    late int periodId;
    setUp(() async => periodId = await periods.startNew(newPeriod()));

    DailyTransaction tx(DateTime date, int amount) => DailyTransaction(
      periodId: periodId,
      date: date,
      amount: amount,
      category: TransactionCategory.transport,
      note: 'ojek',
    );

    test('add dan list terurut dari tanggal terbaru', () async {
      await transactions.add(tx(DateTime(2026, 10, 1), 10000));
      await transactions.add(tx(DateTime(2026, 10, 3), 30000));
      await transactions.add(tx(DateTime(2026, 10, 2), 20000));

      final list = await transactions.listByPeriod(periodId);
      expect(list.map((t) => t.amount), [30000, 20000, 10000]);
      expect(list.first.category, TransactionCategory.transport);
      expect(list.first.note, 'ojek');
    });

    test('update dan delete', () async {
      final id = await transactions.add(tx(DateTime(2026, 10, 1), 10000));
      await transactions.update(
        DailyTransaction(
          id: id,
          periodId: periodId,
          date: DateTime(2026, 10, 1),
          amount: 15000,
          category: TransactionCategory.food,
        ),
      );
      var list = await transactions.listByPeriod(periodId);
      expect(list.single.amount, 15000);
      expect(list.single.category, TransactionCategory.food);

      await transactions.delete(id);
      list = await transactions.listByPeriod(periodId);
      expect(list, isEmpty);
    });

    test('amount <= 0 ditolak oleh constraint DB', () async {
      expect(
        transactions.add(tx(DateTime(2026, 10, 1), 0)),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('data anak ikut terhapus saat periode dihapus (cascade)', () async {
      await fixed.add(FixedExpense(periodId: periodId, name: 'Kos', amount: 1));
      await transactions.add(tx(DateTime(2026, 10, 1), 10000));

      await db.delete(
        DbTables.budgetPeriod,
        where: 'id = ?',
        whereArgs: [periodId],
      );

      expect(await fixed.listByPeriod(periodId), isEmpty);
      expect(await transactions.listByPeriod(periodId), isEmpty);
    });

    test('listRecentDates mengembalikan tanggal unik terbaru dulu', () async {
      await transactions.add(tx(DateTime(2026, 10, 1), 10000));
      await transactions.add(tx(DateTime(2026, 10, 3), 30000));
      await transactions.add(tx(DateTime(2026, 10, 3), 5000));

      expect(await transactions.listRecentDates(), [
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 1),
      ]);
      expect(await transactions.listRecentDates(limit: 1), [
        DateTime(2026, 10, 3),
      ]);
    });
  });

  group('hapus data', () {
    test('delete menghapus periode arsip beserta datanya', () async {
      final old = await periods.startNew(newPeriod());
      await fixed.add(FixedExpense(periodId: old, name: 'Kos', amount: 1));
      await transactions.add(
        DailyTransaction(
          periodId: old,
          date: DateTime(2026, 10, 1),
          amount: 10000,
          category: TransactionCategory.food,
        ),
      );
      final active = await periods.startNew(newPeriod(income: 5000000));

      await periods.delete(old);

      expect(await periods.getById(old), isNull);
      expect(await fixed.listByPeriod(old), isEmpty);
      expect(await transactions.listByPeriod(old), isEmpty);
      expect((await periods.getActive())?.id, active);
    });

    test('delete tidak menghapus periode aktif', () async {
      final active = await periods.startNew(newPeriod());
      await periods.delete(active);
      expect((await periods.getActive())?.id, active);
    });

    test('deleteAll mengosongkan semua tabel', () async {
      final id = await periods.startNew(newPeriod());
      await fixed.add(FixedExpense(periodId: id, name: 'Kos', amount: 1));
      await transactions.add(
        DailyTransaction(
          periodId: id,
          date: DateTime(2026, 10, 1),
          amount: 10000,
          category: TransactionCategory.food,
        ),
      );

      await periods.deleteAll();

      for (final table in [
        DbTables.budgetPeriod,
        DbTables.fixedExpense,
        DbTables.dailyTransaction,
      ]) {
        expect(await db.query(table), isEmpty, reason: table);
      }
    });
  });
}
