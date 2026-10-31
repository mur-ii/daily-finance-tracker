import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../data/no_spend_days_prefs.dart';
import '../data/sqflite_repositories.dart';
import '../domain/budget_calculator.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/streak_calculator.dart';
import '../domain/transaction_rules.dart';

final budgetPeriodRepositoryProvider = Provider<BudgetPeriodRepository>(
  (ref) => SqfliteBudgetPeriodRepository(ref.watch(appDatabaseProvider)),
);

final fixedExpenseRepositoryProvider = Provider<FixedExpenseRepository>(
  (ref) => SqfliteFixedExpenseRepository(ref.watch(appDatabaseProvider)),
);

final transactionRepositoryProvider = Provider<DailyTransactionRepository>(
  (ref) => SqfliteDailyTransactionRepository(ref.watch(appDatabaseProvider)),
);

/// "Sekarang"; di-override di test.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

/// Periode anggaran aktif (null jika user belum melakukan setup).
final activePeriodProvider =
    AsyncNotifierProvider<ActivePeriodNotifier, BudgetPeriod?>(
      ActivePeriodNotifier.new,
    );

class ActivePeriodNotifier extends AsyncNotifier<BudgetPeriod?> {
  @override
  Future<BudgetPeriod?> build() =>
      ref.watch(budgetPeriodRepositoryProvider).getActive();

  /// Membuat periode baru dan menonaktifkan yang lama. Jika
  /// [carryOverFixedExpenses], tagihan wajib periode lama disalin.
  Future<void> startNew({
    required int totalIncome,
    required DateTime startDate,
    required int daysCount,
    bool carryOverFixedExpenses = false,
  }) async {
    final fixedRepo = ref.read(fixedExpenseRepositoryProvider);
    final previous = await future;

    final carried = carryOverFixedExpenses && previous?.id != null
        ? await fixedRepo.listByPeriod(previous!.id!)
        : const <FixedExpense>[];

    final newId = await ref
        .read(budgetPeriodRepositoryProvider)
        .startNew(
          BudgetPeriod(
            totalIncome: totalIncome,
            startDate: dateOnly(startDate),
            daysCount: daysCount,
          ),
        );
    for (final e in carried) {
      await fixedRepo.add(
        FixedExpense(periodId: newId, name: e.name, amount: e.amount),
      );
    }

    ref.invalidateSelf();
    await future;
  }

  /// Menghapus periode arsip (periode aktif tidak bisa dihapus).
  Future<void> deleteArchived(int id) async {
    await ref.read(budgetPeriodRepositoryProvider).delete(id);
    ref.invalidate(periodHistoryProvider);
  }

  /// Menghapus semua data. Router akan mengarahkan user kembali ke setup.
  Future<void> resetAll() async {
    await ref.read(budgetPeriodRepositoryProvider).deleteAll();
    await clearNoSpendDays();
    ref
      ..invalidate(noSpendDaysProvider)
      ..invalidate(periodHistoryProvider)
      ..invalidateSelf();
    await future;
  }
}

/// Pengeluaran wajib milik periode aktif.
final fixedExpensesProvider =
    AsyncNotifierProvider<FixedExpensesNotifier, List<FixedExpense>>(
      FixedExpensesNotifier.new,
    );

class FixedExpensesNotifier extends AsyncNotifier<List<FixedExpense>> {
  @override
  Future<List<FixedExpense>> build() async {
    final period = await ref.watch(activePeriodProvider.future);
    if (period == null) return const [];
    return ref.watch(fixedExpenseRepositoryProvider).listByPeriod(period.id!);
  }

  Future<void> add({required String name, required int amount}) async {
    final period = await ref.read(activePeriodProvider.future);
    if (period == null) {
      throw StateError('Tidak ada periode aktif.');
    }
    await ref
        .read(fixedExpenseRepositoryProvider)
        .add(
          FixedExpense(periodId: period.id!, name: name.trim(), amount: amount),
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(
    FixedExpense expense, {
    required String name,
    required int amount,
  }) async {
    await ref
        .read(fixedExpenseRepositoryProvider)
        .update(
          FixedExpense(
            id: expense.id,
            periodId: expense.periodId,
            name: name.trim(),
            amount: amount,
          ),
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(int id) async {
    await ref.read(fixedExpenseRepositoryProvider).delete(id);
    ref.invalidateSelf();
    await future;
  }

  /// Menyamakan tagihan periode aktif dengan [draft]. Item tanpa id ditambahkan,
  /// item tersimpan yang tidak ada di [draft] dihapus.
  Future<void> saveDraft(List<FixedExpense> draft) async {
    final period = await ref.read(activePeriodProvider.future);
    if (period == null) {
      throw StateError('Tidak ada periode aktif.');
    }
    final repo = ref.read(fixedExpenseRepositoryProvider);
    final saved = await repo.listByPeriod(period.id!);
    final savedById = {for (final e in saved) e.id: e};
    final draftIds = {for (final e in draft) e.id};

    await repo.saveChanges(
      added: [
        for (final e in draft)
          if (e.id == null) e,
      ],
      updated: [
        for (final e in draft)
          if (e.id != null &&
              (savedById[e.id]?.name != e.name ||
                  savedById[e.id]?.amount != e.amount))
            e,
      ],
      removedIds: [
        for (final e in saved)
          if (!draftIds.contains(e.id)) e.id!,
      ],
    );
    ref.invalidateSelf();
    await future;
  }
}

/// Transaksi harian milik periode aktif (terbaru di atas).
final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<DailyTransaction>>(
      TransactionsNotifier.new,
    );

class TransactionsNotifier extends AsyncNotifier<List<DailyTransaction>> {
  @override
  Future<List<DailyTransaction>> build() async {
    final period = await ref.watch(activePeriodProvider.future);
    if (period == null) return const [];
    return ref.watch(transactionRepositoryProvider).listByPeriod(period.id!);
  }

  /// Menambah (id null) atau memperbarui transaksi. Tanggal harus berada di
  /// dalam periode aktif.
  Future<void> save(DailyTransaction transaction) async {
    final period = await ref.read(activePeriodProvider.future);
    if (period == null) {
      throw StateError('Tidak ada periode aktif.');
    }
    if (!isDateWithinPeriod(period, transaction.date)) {
      throw ArgumentError.value(
        transaction.date,
        'date',
        'Tanggal di luar periode aktif',
      );
    }

    final toSave = DailyTransaction(
      id: transaction.id,
      periodId: period.id!,
      date: dateOnly(transaction.date),
      amount: transaction.amount,
      category: transaction.category,
      note: transaction.note.trim(),
    );
    final repo = ref.read(transactionRepositoryProvider);
    if (toSave.id == null) {
      await repo.add(toSave);
    } else {
      await repo.update(toSave);
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(int id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    ref.invalidateSelf();
    await future;
  }
}

class DashboardData {
  const DashboardData({
    required this.period,
    required this.summary,
    required this.transactions,
    this.fixedExpenses = const [],
  });

  final BudgetPeriod period;
  final BudgetSummary summary;
  final List<DailyTransaction> transactions;
  final List<FixedExpense> fixedExpenses;
}

Future<DashboardData> _loadPeriodData(Ref ref, BudgetPeriod period) async {
  final fixed = await ref
      .read(fixedExpenseRepositoryProvider)
      .listByPeriod(period.id!);
  final transactions = await ref
      .read(transactionRepositoryProvider)
      .listByPeriod(period.id!);
  return DashboardData(
    period: period,
    summary: BudgetCalculator.calculate(
      period: period,
      fixedExpenses: fixed,
      transactions: transactions,
      today: ref.read(todayProvider),
    ),
    transactions: transactions,
    fixedExpenses: fixed,
  );
}

/// Semua periode (aktif dan arsip) beserta ringkasannya, terbaru dulu.
final periodHistoryProvider = FutureProvider.autoDispose<List<DashboardData>>((
  ref,
) async {
  final periods = await ref.watch(budgetPeriodRepositoryProvider).listAll();
  return [for (final p in periods) await _loadPeriodData(ref, p)];
});

/// Detail satu periode (read-only). Null jika id tidak ditemukan.
final periodDetailProvider = FutureProvider.autoDispose
    .family<DashboardData?, int>((ref, id) async {
      final period = await ref
          .watch(budgetPeriodRepositoryProvider)
          .getById(id);
      return period == null ? null : _loadPeriodData(ref, period);
    });

/// Gabungan periode + kalkulasi + transaksi untuk dashboard.
/// Null jika belum ada periode aktif.
final dashboardProvider = FutureProvider<DashboardData?>((ref) async {
  final period = await ref.watch(activePeriodProvider.future);
  if (period == null) return null;
  final fixed = await ref.watch(fixedExpensesProvider.future);
  final transactions = await ref.watch(transactionsProvider.future);
  final today = ref.watch(todayProvider);

  return DashboardData(
    period: period,
    summary: BudgetCalculator.calculate(
      period: period,
      fixedExpenses: fixed,
      transactions: transactions,
      today: today,
    ),
    transactions: transactions,
  );
});

/// Hari yang ditandai "tidak jajan" (disimpan di SharedPreferences).
final noSpendDaysProvider =
    AsyncNotifierProvider<NoSpendDaysNotifier, List<DateTime>>(
      NoSpendDaysNotifier.new,
    );

class NoSpendDaysNotifier extends AsyncNotifier<List<DateTime>> {
  @override
  Future<List<DateTime>> build() => loadNoSpendDays();

  Future<void> markToday() async {
    await markNoSpendDay(dateOnly(ref.read(todayProvider)));
    ref.invalidateSelf();
    await future;
  }
}

class StreakInfo {
  const StreakInfo({required this.days, required this.recordedToday});

  /// Jumlah hari berturut-turut yang tercatat.
  final int days;

  /// True jika hari ini sudah ada transaksi atau ditandai tidak jajan.
  final bool recordedToday;
}

/// Streak pencatatan lintas periode.
final streakProvider = FutureProvider<StreakInfo>((ref) async {
  // Dihitung ulang setiap kali transaksi periode aktif berubah.
  await ref.watch(transactionsProvider.future);
  final noSpend = await ref.watch(noSpendDaysProvider.future);
  final today = dateOnly(ref.watch(todayProvider));
  final dates = await ref
      .watch(transactionRepositoryProvider)
      .listRecentDates();
  final recorded = [...dates, ...noSpend];

  return StreakInfo(
    days: StreakCalculator.calculate(recorded, today),
    recordedToday: recorded.any((d) => dateOnly(d) == today),
  );
});
