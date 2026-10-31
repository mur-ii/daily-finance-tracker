import 'entities.dart';

abstract interface class BudgetPeriodRepository {
  /// Periode yang sedang aktif, atau null jika belum ada.
  Future<BudgetPeriod?> getActive();

  /// Membuat periode baru sebagai periode aktif dan menonaktifkan yang lama.
  /// Mengembalikan id periode baru.
  Future<int> startNew(BudgetPeriod period);

  /// Semua periode (aktif dan arsip), terbaru dulu.
  Future<List<BudgetPeriod>> listAll();

  Future<BudgetPeriod?> getById(int id);

  /// Menghapus periode arsip beserta tagihan & transaksinya. Periode aktif
  /// tidak ikut terhapus.
  Future<void> delete(int id);

  /// Menghapus semua periode, tagihan, dan transaksi.
  Future<void> deleteAll();
}

abstract interface class FixedExpenseRepository {
  Future<List<FixedExpense>> listByPeriod(int periodId);
  Future<int> add(FixedExpense expense);

  /// Menerapkan sekumpulan perubahan sekaligus: semua berhasil atau tidak sama
  /// sekali.
  Future<void> saveChanges({
    required List<FixedExpense> added,
    required List<FixedExpense> updated,
    required List<int> removedIds,
  });
}

abstract interface class DailyTransactionRepository {
  /// Urut dari tanggal terbaru, lalu id terbaru.
  Future<List<DailyTransaction>> listByPeriod(int periodId);

  /// Tanggal unik yang punya transaksi (semua periode), terbaru dulu.
  Future<List<DateTime>> listRecentDates({int limit = 400});

  Future<int> add(DailyTransaction transaction);
  Future<void> update(DailyTransaction transaction);
  Future<void> delete(int id);
}
