import 'package:restaurant_billing/data/database/database_helper.dart';
import 'package:restaurant_billing/data/models/todo_model.dart';

class TodoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create a new todo
  Future<int> createTodo(TodoModel todo) async {
    final db = await _dbHelper.database;
    return await db.insert('todos', todo.toMap());
  }

  // Get all todos
  Future<List<TodoModel>> getAllTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  // Get todos by completion status
  Future<List<TodoModel>> getTodosByStatus({required bool isCompleted}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'isCompleted = ?',
      whereArgs: [isCompleted ? 1 : 0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  // Get todo by ID
  Future<TodoModel?> getTodoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TodoModel.fromMap(maps.first);
  }

  // Update a todo
  Future<int> updateTodo(TodoModel todo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Toggle todo completion status
  Future<int> toggleTodoComplete(int id) async {
    final db = await _dbHelper.database;
    final todo = await getTodoById(id);
    if (todo == null) return 0;
    
    return await db.update(
      'todos',
      {'isCompleted': todo.isCompleted ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a todo
  Future<int> deleteTodo(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get todos related to a specific expense
  Future<List<TodoModel>> getTodosByExpense(int expenseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'relatedExpenseId = ?',
      whereArgs: [expenseId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  // Get counts for dashboard
  Future<Map<String, int>> getTodoCounts() async {
    final db = await _dbHelper.database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM todos');
    final completedResult = await db.rawQuery('SELECT COUNT(*) as count FROM todos WHERE isCompleted = 1');
    
    return {
      'total': totalResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'active': (totalResult.first['count'] as int) - (completedResult.first['count'] as int),
    };
  }
}
