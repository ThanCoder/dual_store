// ignore_for_file: avoid_print

import 'package:ep_ui/dialog/error_alert_dialog.dart';
import 'package:ep_ui/dialog/prompt_alert_dialog.dart';
import 'package:ep_ui/dialog/success_alert_dialog.dart';
import 'package:flutter/material.dart';

import 'package:dual_store/dual_store.dart';

class TodoApp extends StatefulWidget {
  const new({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  @override
  void initState() {
    store.registerAdapter(TodoAdapter());
    init();
    super.initState();
    store.events.error.all.listen((event) {
      print('[Du Error Event]: $event');
    });
    store.events.box.all.listen((event) {
      print('Box Event: $event');
      print('lastId: ${store.state.lastId}');
      print('deletedCount: ${store.state.deletedCount}');
      print('deletedSize: ${store.state.deletedSize}');
      checkCompact();
    });
    store.events.open.listen((event) {
      checkCompact();
    });
  }

  @override
  void dispose() {
    store.close();
    super.dispose();
  }

  final store = DualStore();
  DuBox<Todo> get todoBox => store.getBox<Todo>();
  final path = '/home/thancoder/Documents/todo.du';
  bool needToCompact = false;

  Future<void> init() async {
    await store.open(path);
  }

  void checkCompact() {
    if (store.state.deletedCount > 0) {
      if (!mounted) return;
      setState(() {
        needToCompact = true;
      });
    }
  }

  void addTodo() async {
    final text = await showPromptAlertDialog(
      context,
      'Untitled',
      confirmText: 'New Todo',
    );
    if (!mounted) return;
    if (text == null) return;

    final todo = Todo(title: text, checked: false, date: .now());
    final res = await todoBox.add(todo);
    if (!mounted) return;
    if (res.isErr) {
      showErrorDialog(context, res.unwrapError());
      return;
    }
  }

  void compact() async {
    final res = await store.compact();
    if (!mounted) return;

    if (res.isErr) {
      showErrorDialog(context, res.unwrapError());
      return;
    }
    showSuccessDialog(context, 'Compact လုပ်ပြီးပါပြီ');
    setState(() {});
  }

  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
        actions: [
          if (needToCompact)
            FilledButton(onPressed: compact, child: Text('DB Compact')),
        ],
      ),
      body: StreamBuilder(
        stream: store.events.open,
        builder: (context, asyncSnapshot) {
          return CustomScrollView(
            slivers: [
              StreamBuilder(
                stream: todoBox.events.all,
                builder: (context, asyncSnapshot) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: .all(10),
                      decoration: BoxDecoration(
                        color: col.surfaceContainer,
                        borderRadius: .circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'LastId: ${store.state.lastId}',
                            style: TextStyle(fontSize: 18, fontWeight: .w600),
                          ),
                          Text(
                            'deletedCount: ${store.state.deletedCount}',
                            style: TextStyle(fontSize: 18, fontWeight: .w600),
                          ),
                          Text(
                            'deletedSize: ${store.state.deletedSize}',
                            style: TextStyle(fontSize: 18, fontWeight: .w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SliverPadding(padding: .all(10), sliver: _listWidget),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: addTodo),
    );
  }

  Widget get _listWidget {
    return StreamBuilder(
      stream: todoBox.events.all,
      builder: (context, snapshot) {
        return FutureBuilder(
          future: todoBox.getAll(),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            list.sort((a, b) => b.date.compareTo(a.date));
            return SliverList.separated(
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return _listItem(item);
              },
            );
          },
        );
      },
    );
  }

  Container _listItem(Todo item) {
    return Container(
      padding: .symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: .circular(14),
        boxShadow: [.new(blurRadius: 8, color: col.primary, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Row(
                  children: [
                    Text(
                      'ID: ${item.generatedId}',

                      style: TextStyle(fontSize: 20, fontWeight: .w600),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Title: ${item.title}',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: .w600,
                        decoration: item.checked ? .lineThrough : null,
                      ),
                    ),
                    SizedBox(width: 20),
                    Checkbox.adaptive(
                      value: item.checked,
                      onChanged: (value) async {
                        todoBox.update(
                          item.generatedId,
                          value: item.copyWith(checked: value),
                        );
                      },
                    ),
                  ],
                ),
                Text('Date: ${item.date.toIso8601String()}'),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: col.error,
              foregroundColor: col.onError,
            ),
            onPressed: () async {
              // todoBox.deleteById(item.generatedId);
              await item.delete();
            },
            label: Text('Delete'),
            icon: Icon(Icons.delete_forever_outlined),
          ),
        ],
      ),
    );
  }
}

class Todo extends IDuModel {
  final String title;
  final bool checked;
  final DateTime date;

  Todo({required this.title, required this.checked, required this.date});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'checked': checked,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      checked: json['checked'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    );
  }

  Todo copyWith({String? title, bool? checked, DateTime? date}) {
    return Todo(
      title: title ?? this.title,
      checked: checked ?? this.checked,
      date: date ?? this.date,
    );
  }
}

class TodoAdapter extends IDuBinaryMetaAdapter<Todo> {
  @override
  int get adapterId => 1;

  @override
  Todo fromMap(Map<String, dynamic> map) {
    return .fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(Todo value) {
    return value.toJson();
  }
}
