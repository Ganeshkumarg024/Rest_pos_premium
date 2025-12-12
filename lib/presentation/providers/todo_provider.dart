import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/data/models/todo_model.dart';
import 'package:restaurant_billing/data/repositories/todo_repository.dart';

// Repository provider
final todoRepositoryProvider = Provider((ref) => TodoRepository());

// Todos list provider
final todosProvider = StateNotifierProvider<TodosNotifier, AsyncValue<List<TodoModel>>>((ref) {
  return TodosNotifier(ref.read(todoRepositoryProvider));
});

class TodosNotifier extends StateNotifier<AsyncValue<List<TodoModel>>> {
  final TodoRepository _repository;
  String _filterStatus = 'all'; // all, active, completed

  TodosNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    state = const AsyncValue.loading();
    try {
      List<TodoModel> todos;
      switch (_filterStatus) {
        case 'active':
          todos = await _repository.getTodosByStatus(isCompleted: false);
          break;
        case 'completed':
          todos = await _repository.getTodosByStatus(isCompleted: true);
          break;
        default:
          todos = await _repository.getAllTodos();
      }
      state = AsyncValue.data(todos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void setFilter(String filter) {
    _filterStatus = filter;
    loadTodos();
  }

  String get currentFilter => _filterStatus;

  Future<bool> addTodo(TodoModel todo) async {
    try {
      await _repository.createTodo(todo);
      await loadTodos();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateTodo(TodoModel todo) async {
    try {
      await _repository.updateTodo(todo);
      await loadTodos();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> toggleComplete(int id) async {
    try {
      await _repository.toggleTodoComplete(id);
      await loadTodos();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteTodo(int id) async {
    try {
      await _repository.deleteTodo(id);
      await loadTodos();
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Todo counts provider for dashboard
final todoCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(todoRepositoryProvider);
  return await repository.getTodoCounts();
});
