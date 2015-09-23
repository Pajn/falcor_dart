library falcor_dart.example;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'package:falcor_dart/falcor_dart.dart';
import 'package:falcor_dart/shelf.dart';

/// Example using shelf binding
main() async {
  final todoService = new TodosService();

  final falcorHandler = await createFalcorHandler((_) {
    return new Router([
      route('todos.name', get: (_) async {
        var todoList = await todoService.getTodoList();

        return {
          'path': ['todos', 'name'],
          'value': todoList.map((todo) => todo['name']),
        };
      }),
      route('todos.length', get: (_) async {
        var todoList = await todoService.getTodoList();

        return {
          'path': ['todos', 'length'],
          'value': todoList.length,
        };
      })
    ]);
  });

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(falcorHandler);

  var server = await io.serve(handler, 'localhost', 8080);

  print('Serving at http://${server.address.host}:${server.port}');
}

class TodosService {
  getTodoList() async {
    return [
      {'name': 'Create Router'},
      {'name': 'Create request handler'},
      {'name': 'Send requests'},
    ];
  }
}
