import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/data/models/expense_model.dart';
import 'package:restaurant_billing/data/repositories/expense_repository.dart';

// Repository provider
final expenseRepositoryProvider = Provider((ref) => ExpenseRepository());

// Expense list provider
final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  return ExpensesNotifier(ref.read(expenseRepositoryProvider));
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;

  ExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _repository.getAllExpenses();
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _repository.getExpensesByDateRange(startDate, endDate);
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      await _repository.createExpense(expense);
      await loadExpenses();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Expense stats provider
final expenseStatsProvider = FutureProvider.family<Map<String, dynamic>, DateRange>((ref, dateRange) async {
  final repository = ref.read(expenseRepositoryProvider);
  
  final total = await repository.getTotalExpenses(dateRange.start, dateRange.end);
  final byCategory = await repository.getExpensesByCategorySummary(dateRange.start, dateRange.end);
  
  return {
    'total': total,
    'byCategory': byCategory,
  };
});

// Today's expenses provider
final todayExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getTodayExpenses();
});

// This month's expenses provider  
final monthExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(expenseRepositoryProvider);
  return await repository.getMonthExpenses();
});

// Date range helper class
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}
