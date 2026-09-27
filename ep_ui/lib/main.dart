import 'package:ep_ui/todo_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: const MyApp()));
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListTile(
        title: Text("Todo App"),
        onTap: () {
          context.go(builder: (mainCtx) => TodoApp());
        },
      ),
    );
  }
}

extension BCX on BuildContext {
  void go({required Widget Function(BuildContext mainCtx) builder}) {
    Navigator.push(this, MaterialPageRoute(builder: builder));
  }
}
