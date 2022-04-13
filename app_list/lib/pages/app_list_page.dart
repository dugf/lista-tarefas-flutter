import 'package:app_list/models/todo.dart';
import 'package:app_list/pages/widgets/todo_list_item.dart';
import 'package:app_list/repositories/todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xff26e07f),
          title: const Text(
            'Lista de Tarefas',
            style: TextStyle(
              fontSize: 32,
            ),
          ),
          elevation: 1,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Ex. Beber água',
                          errorText: errorText,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff26e07f),
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: errorText != null
                                ? Colors.red
                                : const Color(0xff26e07f),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'O título não pode ser vazio!';
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff26e07f),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        todos.length == 1
                            ? 'Você possui 1 tarefa pendente'
                            : 'Você possui ${todos.length} tarefas pendentes',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: verifyCleanAll,
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff26e07f),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Limpar tudo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso',
          style: const TextStyle(
            color: Color(0xff060708),
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xff26e07f),
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void verifyCleanAll() {
    if (todos.isEmpty) {
      Fluttertoast.showToast(
        msg: "Não há tarefas para serem apagadas!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limpar Tudo?'),
          content: const Text(
              'Todas as suas tarefas serão definitivamente excluídas.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(primary: const Color(0xff26e07f)),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deletAllTodos();
              },
              style: TextButton.styleFrom(primary: Colors.red),
              child: const Text('Limpar tudo'),
            ),
          ],
        ),
      );
    }
  }

  void deletAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
