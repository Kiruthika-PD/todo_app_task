
import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_api_service.dart';
import '../widgets/todo_card.dart';
import 'create_todo_screen.dart';
import 'update_todo_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  TodoApiService todoApiService = TodoApiService();

  List<TodoModel> todoArray = [];

  @override
  void initState() {
    super.initState();
    loadTodoArray();
  }

  Future<void> loadTodoArray() async {
    try {
      List<TodoModel> loadedTodoArray =
          await todoApiService.getTodoArray();

      if (!mounted) {
        return;
      }

      setState(() {
        todoArray = loadedTodoArray;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load tasks from server'),
        ),
      );
    }
  }

  int get completedCount {
    return todoArray.where((todo) => todo.completed).length;
  }

  Future<void> createTodo() async {
    String? title = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTodoScreen(),
      ),
    );

    if (title == null) {
      return;
    }

    try {
      TodoModel createdTodo = await todoApiService.createTodo({
        'title': title,
        'completed': false,
      });

      if (!mounted) {
        return;
      }

      setState(() {
        todoArray.add(createdTodo);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save task to server'),
        ),
      );
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    String? title = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTodoScreen(todo: todo),
      ),
    );

    if (title == null) {
      return;
    }

    try {
      TodoModel updatedTodo = await todoApiService.updateTodo(
        todo.id,
        {'title': title},
      );

      if (!mounted) {
        return;
      }

      setState(() {
        todo.title = updatedTodo.title;
        todo.completed = updatedTodo.completed;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task on server'),
        ),
      );
    }
  }

  Future<void> toggleTodo(TodoModel todo, bool? value) async {
    bool completedValue = value ?? false;

    try {
      TodoModel updatedTodo = await todoApiService.updateTodo(
        todo.id,
        {'completed': completedValue},
      );

      if (!mounted) {
        return;
      }

      setState(() {
        todo.completed = updatedTodo.completed;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task completion'),
        ),
      );
    }
  }

  Future<void> deleteTodo(TodoModel todo) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text(
            'Are you sure you want to delete "${todo.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await todoApiService.deleteTodo(todo.id);

      if (!mounted) {
        return;
      }

      setState(() {
        todoArray.remove(todo);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete task from server'),
        ),
      );
    }
  }

  Future<void> deleteAllTodos() async {
    if (todoArray.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no tasks to delete'),
        ),
      );
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete all tasks?'),
          content: const Text(
            'Are you sure you want to delete all tasks? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete all'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      for (TodoModel todo in List<TodoModel>.from(todoArray)) {
        await todoApiService.deleteTodo(todo.id);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        todoArray.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All tasks deleted'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete all tasks. Some tasks may already be deleted.',
          ),
        ),
      );

      await loadTodoArray();
    }
  }

  Future<void> completeAllTodos() async {
    if (todoArray.isEmpty) {
      return;
    }

    try {
      List<TodoModel> updatedTodoArray = [];

      for (TodoModel todo in List<TodoModel>.from(todoArray)) {
        if (!todo.completed) {
          TodoModel updatedTodo = await todoApiService.updateTodo(
            todo.id,
            {'completed': true},
          );

          updatedTodoArray.add(updatedTodo);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        for (TodoModel updatedTodo in updatedTodoArray) {
          int todoIndex = todoArray.indexWhere(
            (todo) => todo.id == updatedTodo.id,
          );

          if (todoIndex != -1) {
            todoArray[todoIndex].completed = updatedTodo.completed;
          }
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete all tasks'),
        ),
      );

      await loadTodoArray();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/task_space_logo.png',
              height: 78,
              width: 210,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Task options',
            onSelected: (value) {
              if (value == 'complete_all') {
                completeAllTodos();
              }

              if (value == 'delete_all') {
                deleteAllTodos();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'complete_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Mark all as completed'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text('Delete all tasks'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (todoArray.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 4, 28, 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E5FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your progress',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF174A8B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedCount of ${todoArray.length} tasks completed',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF174A8B),
                        ),
                      ),
                    ],
                  ),
                ),
              if (todoArray.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E5FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 46,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Start your day here!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174A8B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            'You have no tasks yet.\nAdd a task and make your productive!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  itemCount: todoArray.length,
                  itemBuilder: (context, index) {
                    TodoModel todo = todoArray[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TodoCard(
                        todo: todo,
                        onCompletedChanged: (value) {
                          toggleTodo(todo, value);
                        },
                        onEdit: () {
                          updateTodo(todo);
                        },
                        onDelete: () {
                          deleteTodo(todo);
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -15),
        child: FloatingActionButton.extended(
          onPressed: createTodo,
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
