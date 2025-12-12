import 'package:sqflite/sqflite.dart';
import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/data/models/expense_model.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create expense
  Future<int> createExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  // Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String().substring(0, 10),
        endDate.toIso8601String().substring(0, 10),
      ],
      orderBy: 'date DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  // Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  // Get single expense
  Future<ExpenseModel?> getExpense(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ExpenseModel.fromMap(maps.first);
    }
    return null;
  }

  // Update expense
  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete expense
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total expenses for date range
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM expenses
      WHERE date >= ? AND date <= ?
    ''', [
      startDate.toIso8601String().substring(0, 10),
      endDate.toIso8601String().substring(0, 10),
    ]);
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get expenses by category summary
  Future<Map<String, double>> getExpensesByCategorySummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE date >= ? AND date <= ?
      GROUP BY category
      ORDER BY total DESC
    ''', [
      startDate.toIso8601String().substring(0, 10),
      endDate.toIso8601String().substring(0, 10),
    ]);
    
    final Map<String, double> summary = {};
    for (var row in result) {
      summary[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return summary;
  }

  // Get today's expenses
  Future<double> getTodayExpenses() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return await getTotalExpenses(startOfDay, endOfDay);
  }

  // Get this month's expenses
  Future<double> getMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return await getTotalExpenses(startOfMonth, endOfMonth);
  }
}
