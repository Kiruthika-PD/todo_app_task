import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final ValueChanged<bool?> onCompletedChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onCompletedChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: todo.completed,
              onChanged: onCompletedChanged,
            ),
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.completed
                      ? Colors.grey
                      : null,
                ),
              ),
            ),
            
        // Edit button — Green
        IconButton(
          onPressed: onEdit,
          icon: const Icon(
            Icons.edit_outlined,
            color: Color(0xFF2EAD70),
          ),
          tooltip: 'Edit task',
        ),

        // Delete button — Blue
        IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFF1976D2),
          ),
          tooltip: 'Delete task',
        ),

          ],
        ),
      ),
    );
  }
}
