import 'package:dio/dio.dart';
import '../models/todo_model.dart';

class TodoApiService {
  final String baseUrl = 'http://64.227.163.157:5003';

  final Dio dio = Dio();

  Future<List<TodoModel>> getTodoArray() async {
    try {
      final response = await dio.get('$baseUrl/todos');

      final List<dynamic> todoJsonArray = response.data;

      return todoJsonArray
          .map((todoJson) => TodoModel.fromJson(todoJson))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load tasks: ${e.message}');
    }
  }

  Future<TodoModel> createTodo(
    Map<String, dynamic> todoData,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/todos',
        data: todoData,
      );

      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create task: ${e.message}');
    }
  }

  Future<TodoModel> updateTodo(
    String todoId,
    Map<String, dynamic> todoData,
  ) async {
    try {
      final response = await dio.patch(
        '$baseUrl/todos/$todoId',
        data: todoData,
      );

      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update task: ${e.message}');
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await dio.delete('$baseUrl/todos/$todoId');
    } on DioException catch (e) {
      throw Exception('Failed to delete task: ${e.message}');
    }
  }
}