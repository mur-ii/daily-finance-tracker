import 'package:daily_tracking/features/daily_tracking/domain/entities.dart';
import 'package:daily_tracking/features/daily_tracking/domain/repositories.dart';

class FakeBudgetPeriodRepository implements BudgetPeriodRepository {
  final List<BudgetPeriod> items = [];

  @override
  Future<BudgetPeriod?> getActive() async {
    final active = items.where((p) => p.isActive);
    return active.isEmpty ? null : active.last;
  }

  @override
  Future<int> startNew(BudgetPeriod period) async {
    final id = items.length + 1;
    items
      ..replaceRange(0, items.length, [
        for (final p in items)
          BudgetPeriod(
            id: p.id,
            totalIncome: p.totalIncome,
            startDate: p.startDate,
            daysCount: p.daysCount,
            isActive: false,
          ),
      ])
      ..add(
        BudgetPeriod(
          id: id,
          totalIncome: period.totalIncome,
          startDate: period.startDate,
          daysCount: period.daysCount,
        ),
      );
    return id;
  }

  @override
  Future<List<BudgetPeriod>> listAll() async {
    return items.toList()..sort((a, b) {
      final byDate = b.startDate.compareTo(a.startDate);
      return byDate != 0 ? byDate : b.id!.compareTo(a.id!);
    });
  }

  @override
  Future<BudgetPeriod?> getById(int id) async {
    final found = items.where((p) => p.id == id);
    return found.isEmpty ? null : found.first;
  }

  @override
  Future<void> delete(int id) async =>
      items.removeWhere((p) => p.id == id && !p.isActive);

  @override
  Future<void> deleteAll() async => items.clear();
}

class FakeDailyTransactionRepository implements DailyTransactionRepository {
  final List<DailyTransaction> items = [];
  int _nextId = 1;

  @override
  Future<List<DailyTransaction>> listByPeriod(int periodId) async {
    final list = items.where((t) => t.periodId == periodId).toList()
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.id!.compareTo(a.id!);
      });
    return list;
  }

  @override
  Future<List<DateTime>> listRecentDates({int limit = 400}) async {
    final dates = items.map((t) => t.date).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return dates.take(limit).toList();
  }

  @override
  Future<int> add(DailyTransaction t) async {
    final id = _nextId++;
    items.add(
      DailyTransaction(
        id: id,
        periodId: t.periodId,
        date: t.date,
        amount: t.amount,
        category: t.category,
        note: t.note,
      ),
    );
    return id;
  }

  @override
  Future<void> update(DailyTransaction t) async {
    final i = items.indexWhere((e) => e.id == t.id);
    if (i >= 0) items[i] = t;
  }

  @override
  Future<void> delete(int id) async => items.removeWhere((e) => e.id == id);
}

class FakeFixedExpenseRepository implements FixedExpenseRepository {
  final List<FixedExpense> items = [];
  int _nextId = 1;

  @override
  Future<List<FixedExpense>> listByPeriod(int periodId) async =>
      items.where((e) => e.periodId == periodId).toList();

  @override
  Future<int> add(FixedExpense expense) async {
    final id = _nextId++;
    items.add(
      FixedExpense(
        id: id,
        periodId: expense.periodId,
        name: expense.name,
        amount: expense.amount,
      ),
    );
    return id;
  }

  @override
  Future<void> saveChanges({
    required List<FixedExpense> added,
    required List<FixedExpense> updated,
    required List<int> removedIds,
  }) async {
    items.removeWhere((e) => removedIds.contains(e.id));
    for (final expense in updated) {
      final i = items.indexWhere((e) => e.id == expense.id);
      if (i >= 0) items[i] = expense;
    }
    added.forEach(add);
  }
}
