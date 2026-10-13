
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class TodoApiService {
  String baseUrl = 'http://192.168.1.85:5001';

  Future<List<TodoModel>> getTodoArray() async {
    http.Response response = await http.get(
      Uri.parse('$baseUrl/todos'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tasks');
    }

    List<dynamic> todoJsonArray = jsonDecode(response.body);

    return todoJsonArray
        .map((todoJson) => TodoModel.fromJson(todoJson))
        .toList();
  }

  Future<TodoModel> createTodo(Map<String, dynamic> todoData) async {
    http.Response response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todoData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create task: ${response.body}');
    }

    return TodoModel.fromJson(jsonDecode(response.body));
  }

  Future<TodoModel> updateTodo(
    String todoId,
    Map<String, dynamic> todoData,
  ) async {
    http.Response response = await http.patch(
      Uri.parse('$baseUrl/todos/$todoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todoData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.body}');
    }

    return TodoModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTodo(String todoId) async {
    http.Response response = await http.delete(
      Uri.parse('$baseUrl/todos/$todoId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }
}
