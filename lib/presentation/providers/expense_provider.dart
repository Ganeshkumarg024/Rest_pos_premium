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
  String _searchQuery = '';
  String _sortOrder = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc
  ExpenseModel? _lastDeletedExpense;

  ExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      var expenses = await _repository.getAllExpenses();
      expenses = _applySearchAndSort(expenses);
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<ExpenseModel> _applySearchAndSort(List<ExpenseModel> expenses) {
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      expenses = expenses.where((expense) {
        final query = _searchQuery.toLowerCase();
        return expense.category.toLowerCase().contains(query) ||
               (expense.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sorting
    switch (_sortOrder) {
      case 'date_desc':
        expenses.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        expenses.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return expenses;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadExpenses();
  }

  void setSortOrder(String order) {
    _sortOrder = order;
    loadExpenses();
  }

  String get currentSortOrder => _sortOrder;

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

  Future<bool> deleteExpense(int id, {bool saveForUndo = true}) async {
    try {
      if (saveForUndo) {
        // Find and save the expense before deleting
        final currentState = state;
        if (currentState is AsyncData<List<ExpenseModel>>) {
          _lastDeletedExpense = currentState.value.firstWhere((e) => e.id == id);
        }
      }
      await _repository.deleteExpense(id);
      await loadExpenses();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> undoDelete() async {
    if (_lastDeletedExpense == null) return false;
    try {
      await _repository.createExpense(_lastDeletedExpense!);
      _lastDeletedExpense = null;
      await loadExpenses();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  void clearUndoCache() {
    _lastDeletedExpense = null;
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
