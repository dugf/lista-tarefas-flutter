import 'dart:convert';

import 'package:app_list/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

const todoListKey = 'app_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

  void saveTodoList(List<Todo> todos) {
    final jsonString = json.encode(todos);
    sharedPreferences.setString('app_list', jsonString);
  }
}
