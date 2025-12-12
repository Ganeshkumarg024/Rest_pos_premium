import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_billing/core/theme/app_theme.dart';
import 'package:restaurant_billing/data/models/todo_model.dart';
import 'package:restaurant_billing/presentation/providers/todo_provider.dart';
import 'package:restaurant_billing/presentation/screens/todos/add_todo_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            ref.read(todosProvider.notifier).setFilter('all');
            break;
          case 1:
            ref.read(todosProvider.notifier).setFilter('active');
            break;
          case 2:
            ref.read(todosProvider.notifier).setFilter('completed');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(todosProvider.notifier).loadTodos();
        },
        child: todosAsync.when(
          data: (todos) {
            if (todos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No Todos Yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first todo',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Dismissible(
                  key: Key(todo.id.toString()),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 28),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Todo'),
                        content: const Text('Are you sure you want to delete this todo?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await ref.read(todosProvider.notifier).deleteTodo(todo.id!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Todo deleted')),
                      );
                    }
                  },
               child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTodoScreen(todo: todo),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Checkbox
                            Checkbox(
                              value: todo.isCompleted,
                              onChanged: (value) async {
                                await ref.read(todosProvider.notifier).toggleComplete(todo.id!);
                              },
                            ),
                            const SizedBox(width: 12),
                            
                            // Todo Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todo.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                      color: todo.isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                  if (todo.description != null && todo.description!.isNotEmpty) ...                                  [
                                    const SizedBox(height: 4),
                                    Text(
                                      todo.description!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(todo.createdAt),
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Related Expense indicator
                            if (todo.relatedExpenseId != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.link, size: 16, color: AppTheme.primaryColor),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
