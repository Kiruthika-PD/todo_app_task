import 'package:flutter/material.dart';

class CreateTodoScreen extends StatefulWidget {
  const CreateTodoScreen({super.key});

  @override
  State<CreateTodoScreen> createState() => _CreateTodoScreenState();
}

class _CreateTodoScreenState extends State<CreateTodoScreen> {
  String title = '';

  void saveTodo() {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
        ),
      );
      return;
    }

    Navigator.pop(context, title.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'Enter your task',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              onChanged: (value) {
                title = value;
              },
              onSubmitted: (_) => saveTodo(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: saveTodo,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
