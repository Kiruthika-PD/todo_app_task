import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class UpdateTodoScreen extends StatefulWidget {
  final TodoModel todo;

  const UpdateTodoScreen({
    super.key,
    required this.todo,
  });

  @override
  State<UpdateTodoScreen> createState() => _UpdateTodoScreenState();
}

class _UpdateTodoScreenState extends State<UpdateTodoScreen> {
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.todo.title,
    );
  }

  void updateTodo() {
    String title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
        ),
      );
      return;
    }

    Navigator.pop(context, title);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              onSubmitted: (_) => updateTodo(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: updateTodo,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}