# DualStore

**DualStore** is a lightweight local database engine for Dart and Flutter applications.

It provides typed boxes, model adapters, persistent storage, database events, database state tracking, file management, and database compaction.

### Example List

* [x] [Dart Example](#dart-example)
* [x] [DualStore Todo Example](#dualstore-todo-example)
* [x] [Full Flutter App Example](#flutter-app-example)
* [x] [Screenshot](#screenshot)
* [x] [Image Box Example](#image-box-example)


## Features

### Core Database

* 📦 **Typed Boxes**

  * Store and retrieve strongly typed `IDuModel` objects.
  * Access data through `DuBox<T>`.

* 💾 **Persistent Local Storage**

  * Store application data in a local database file.
  * Data remains available after the application is restarted.

* 🔢 **Automatic Record IDs**

  * Records receive automatically generated IDs.
  * Access the generated ID through `generatedId`.

* 🔄 **Database Reload**

  * Reload the current database from disk.
  * Reload conditionally when the database is not already opened.

* 📂 **Change Database Path**

  * Change the active database file path.

* 🔒 **Database Lifecycle Management**

  * Open, reload, flush, and close the database explicitly.

### Model & Adapter System

* 🧩 **Custom Model Adapters**

  * Register custom model types with `IDuMetaAdapter`.
  * Convert Dart models to storage-compatible maps.
  * Restore models from stored data.

* 🏷️ **Type-based Box Access**

  * Retrieve a box using the model type:

```dart
final todoBox = store.getBox<Todo>();
```

* 📝 **Custom Serialization**

  * Models can define their own serialization logic.
  * `toMap()` and `fromMap()` control how model data is stored.

### Reactive Events

* ⚡ **Database Events**

  * Listen for database lifecycle events.

* 📦 **Box Events**

  * Listen for changes made to boxes.

* ❌ **Error Events**

  * Receive database errors through the event system.

* 🔄 **Flutter Reactive UI**

  * Integrates naturally with `StreamBuilder` and other stream-based UI architectures.


Example:

```dart
store.events.box.all.listen((event) {
  print('Box Event: $event');
});
```

### Database State

DualStore exposes database state through `store.state`.

```dart
store.state.lastId
store.state.deletedCount
store.state.deletedSize
```

Available state information includes:

* Current/last generated record ID
* Number of deleted records
* Storage size occupied by deleted records
* Current database state

This information can be used to monitor database usage and determine when maintenance is required.

### Database Maintenance

* 🧹 **Database Compaction**

  * Reclaim space occupied by deleted records.
  * Reduce unused storage inside the database file.

```dart
final result = await store.compact();
```

* 💽 **Flush to Disk**

  * Explicitly flush database contents to disk.

```dart
final result = await store.flush();
```

### Result-based API

Database operations return:

```dart
Result<T, String>
```

instead of requiring exceptions for normal operation failures.

For example:

```dart
final result = await store.open(path);

if (result.isErr) {
  print(result.unwrapError());
}
```

This makes database operations easier to handle explicitly.

---

# Database API

## Create a Store

```dart
final store = DualStore();
```

## Register an Adapter

Register an adapter before accessing its corresponding box.

```dart
store.registerAdapter(TodoAdapter());
```

After registration:

```dart
final todoBox = store.getBox<Todo>();
```

If an adapter has not been registered, `getBox<T>()` throws an exception indicating that the adapter needs to be registered.

---

# Opening a Database

Open a database at a specific path:

```dart
final result = await store.open('/path/to/database.du');
```

The result contains:

* `Ok(true)` when the database is opened
* `Ok(false)` when applicable according to the operation
* `Err(String)` when an error occurs

You can also check whether the database is currently opened:

```dart
if (store.opened) {
  print('Database is open');
}
```

Get the current database path:

```dart
print(store.path);
```

---

# Open If Not Already Opened

If your application may initialize the database multiple times, use:

```dart
final result = await store.openIfNotOpened(path);
```

If the database is already opened, the operation returns:

```dart
Ok(false)
```

Otherwise it opens the database.

---

# Changing the Database Path

The active database file can be changed:

```dart
final result = await store.changePath(
  '/path/to/new_database.du',
);
```

This is useful when an application needs to switch between database files.

---

# Reloading the Database

Reload the current database:

```dart
final result = await store.reload();
```

Or reload only when the database has not already been opened:

```dart
final result = await store.reloadIfNotOpened();
```

---

# Flushing Data

Flush the database contents to disk:

```dart
final result = await store.flush();
```

This can be used when an application needs to explicitly synchronize the database file with the underlying storage.

---

# Closing the Database

Close the database when it is no longer needed:

```dart
final result = await store.close();
```

In Flutter, it is recommended to close the database when the owning component is disposed:

```dart
@override
void dispose() {
  store.close();
  super.dispose();
}
```

---

# Typed Boxes

A box provides typed access to a specific model.

```dart
final DuBox<Todo> todoBox = store.getBox<Todo>();
```

The type parameter ensures that the box works with the expected model type.

For example:

```dart
final todo = Todo(
  title: 'Learn DualStore',
  checked: false,
  date: DateTime.now(),
);

await todoBox.add(todo);
```

---

# Model Adapter

A model adapter connects a Dart model with DualStore's storage system.

```dart
class TodoAdapter extends IDuBinaryMetaAdapter<Todo> {
  @override
  int get adapterId => 1;

  @override
  Todo fromMap(Map<String, dynamic> map) {
    return Todo.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(Todo value) {
    return value.toJson();
  }
}
```

The adapter is responsible for converting between:

```text
Dart Model
    ↕
Map<String, dynamic>
    ↕
DualStore Storage
```

---

# Events

DualStore provides an event system for observing database activity.

## Error Events

```dart
store.events.error.all.listen((event) {
  print('[DualStore Error]: $event');
});
```

## Box Events

```dart
store.events.box.all.listen((event) {
  print('Box Event: $event');
});
```

## Database Open Events

```dart
store.events.open.listen((event) {
  print('Database opened');
});
```

These events can be used to keep a Flutter UI synchronized with database changes.

---

# Database State

The database state is available through:

```dart
final state = store.state;
```

For example:

```dart
print(state.lastId);
print(state.deletedCount);
print(state.deletedSize);
```

## `lastId`

The latest generated record ID.

## `deletedCount`

The number of records that have been deleted.

## `deletedSize`

The amount of storage currently associated with deleted records.

These values can be used to implement database maintenance logic.

---

# Database Compaction

When records are deleted, their storage may remain available for future database maintenance.

DualStore provides:

```dart
final result = await store.compact();
```

A simple maintenance check can be implemented as:

```dart
if (store.state.deletedCount > 0) {
  final result = await store.compact();

  if (result.isErr) {
    print(result.unwrapError());
  }
}
```

This makes it possible for an application to decide when database compaction should be performed.

---

### image box example

* [x] [Go Example List](#example-list)

```dart
  final ad = st.getImageFileAdapter;
  final imgBox = st.getImageBox;

  await imgBox.add(
    .fromFile(
      File(
        '/home/thancoder/Pictures/ChatGPT Image Sep 19, 2026, 02_12_12 PM.png',
      ),
    ),
  );
  await imgBox.deleteById(1);

  for (var f in await imgBox.getAll()) {
    print(f);
    print('id: ${f.generatedId}');
    final d = await f.imageData;
    if (d.isOk) {
      print('data: ${d.unwrap().length}');
    }
    if (d.isErr) {
      print('image error: ${d.unwrapError()}');
    }
  }
```

# Result API

Most database operations use:

```dart
Result<T, String>
```

This allows operations to report success or failure explicitly.

Example:

```dart
final result = await store.open(path);

if (result.isOk) {
  print('Database opened successfully');
}

if (result.isErr) {
  print('Failed to open database: ${result.unwrapError()}');
}
```

This avoids relying exclusively on exceptions for expected database operation failures.

---

# Todo Example

A complete Todo example can be built using:

```dart
class Todo extends IDuModel {
  final String title;
  final bool checked;
  final DateTime date;

  Todo({
    required this.title,
    required this.checked,
    required this.date,
  });

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

  Todo copyWith({
    String? title,
    bool? checked,
    DateTime? date,
  }) {
    return Todo(
      title: title ?? this.title,
      checked: checked ?? this.checked,
      date: date ?? this.date,
    );
  }
}
```

Then register the adapter:

```dart
store.registerAdapter(TodoAdapter());
```

Open the database:

```dart
await store.open('/path/to/todo.du');
```

Get the typed box:

```dart
final todoBox = store.getBox<Todo>();
```

And start working with Todo records:

```dart
await todoBox.add(todo);
```

---

# Typical Architecture

A typical DualStore application can be structured like this:

```text
                    Flutter Application
                           │
                           ▼
                      DualStore
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
        Model Adapters                 Events
             │                           │
             ▼                           ▼
        DuBox<T>                    Event Streams
             │                           │
             └─────────────┬─────────────┘
                           ▼
                     Dual Engine
                           │
                           ▼
                     Database File
```

The application works with typed models and boxes, while the engine handles the underlying database operations.

---

# Feature Overview

| Feature                             | Supported |
| ----------------------------------- | :-------: |
| Persistent local database           |     ✅     |
| Typed `DuBox<T>`                    |     ✅     |
| Custom model adapters               |     ✅     |
| Automatic record IDs                |     ✅     |
| Add records                         |     ✅     |
| Update records                      |     ✅     |
| Delete records                      |     ✅     |
| Database events                     |     ✅     |
| Box events                          |     ✅     |
| Error events                        |     ✅     |
| Database state                      |     ✅     |
| Database reload                     |     ✅     |
| Conditional open                    |     ✅     |
| Change database path                |     ✅     |
| Flush to disk                       |     ✅     |
| Database close                      |     ✅     |
| Database compaction                 |     ✅     |
| `Result<T, String>` API             |     ✅     |
| Flutter `StreamBuilder` integration |     ✅     |

---

# Design Goals

DualStore is designed around a few simple goals:

* Keep the database API small and easy to understand.
* Provide strongly typed access to stored models.
* Avoid unnecessary dependencies.
* Make database errors explicit through `Result`.
* Provide event streams for reactive applications.
* Keep database maintenance accessible through a simple API.
* Work naturally with Dart and Flutter applications.

---

# Example Project

The included Todo example demonstrates the complete workflow:

```text
Create DualStore
       │
       ▼
Register TodoAdapter
       │
       ▼
Open Database
       │
       ▼
Get DuBox<Todo>
       │
       ├──── Add Todo
       │
       ├──── Update Todo
       │
       └──── Delete Todo
       │
       ▼
Listen to Events
       │
       ▼
Monitor Database State
       │
       ▼
Compact Database
       │
       ▼
Close Database
```

---

### Screenshot

* [x] [Go Example List](#example-list)


<p align="center">
  <img src="https://github.com/ThanCoder/dual_store/blob/main/screenshots/d-1.png?raw=true"
     /></p>


## DualStore Todo Example

* [x] [Go Example List](#example-list)

A simple Flutter Todo application demonstrating how to use **DualStore** for local persistent storage.




This example shows how to:

* Open and close a `DualStore` database
* Register a custom model adapter
* Create a typed `DuBox<T>`
* Add, update, and delete records
* Listen to database and box events
* Read database state such as `lastId`, `deletedCount`, and `deletedSize`
* Detect when database compaction is needed
* Compact the database
* Use `IDuModel` with generated record IDs
* Store custom Dart models using JSON-based adapters

## Features

* Add new Todo items
* Mark Todo items as completed
* Delete Todo items
* Display automatically generated record IDs
* Display Todo creation dates
* Monitor database statistics
* Detect deleted records
* Compact the database when deleted records exist
* Reactive UI updates using `StreamBuilder`

## Data Model

The Todo model extends `IDuModel`.

```dart
class Todo extends IDuModel {
  final String title;
  final bool checked;
  final DateTime date;

  Todo({
    required this.title,
    required this.checked,
    required this.date,
  });

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

  Todo copyWith({
    String? title,
    bool? checked,
    DateTime? date,
  }) {
    return Todo(
      title: title ?? this.title,
      checked: checked ?? this.checked,
      date: date ?? this.date,
    );
  }
}
```

Each Todo contains:

| Field         | Type       | Description                          |
| ------------- | ---------- | ------------------------------------ |
| `title`       | `String`   | Todo title                           |
| `checked`     | `bool`     | Completion state                     |
| `date`        | `DateTime` | Creation date                        |
| `generatedId` | `int`      | Automatically generated by DualStore |

## Adapter

DualStore uses an adapter to convert the model to and from a storable representation.

```dart
class TodoAdapter extends IDuBinaryMetaAdapter<Todo> {
  @override
  int get adapterId => 1;

  @override
  Todo fromMap(Map<String, dynamic> map) {
    return Todo.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(Todo value) {
    return value.toJson();
  }
}
```

The `adapterId` uniquely identifies the model adapter inside the database.

## Opening the Database

Create a `DualStore` instance and open the database:

```dart
final store = DualStore();

Future<void> init() async {
  await store.open('[your path]/todo.du');
}
```

Before using the database, register the model adapter:

```dart
store.registerAdapter(TodoAdapter());

await store.open(path);
```

## Accessing a Typed Box

A `DuBox<T>` provides typed access to stored models.

```dart
DuBox<Todo> get todoBox => store.getBox<Todo>();
```

This allows Todo records to be accessed without manually casting objects.

## Adding a Todo

A new Todo can be inserted with `add()`:

```dart
final todo = Todo(
  title: 'Learn DualStore',
  checked: false,
  date: DateTime.now(),
);

final result = await todoBox.add(todo);

if (result.isErr) {
  print(result.unwrapError());
}
```

The generated record ID is available through:

```dart
todo.generatedId
```

## Updating a Todo

A Todo can be updated by its generated ID:

```dart
await todoBox.update(
  item.generatedId,
  item.copyWith(
    checked: true,
  ),
);
```

For example, the checkbox in the UI can update the completion state:

```dart
onChanged: (value) async {
  await todoBox.update(
    item.generatedId,
    item.copyWith(
      checked: value,
    ),
  );
},
```

## Deleting a Todo

A model can delete itself:

```dart
await item.delete();
```

This removes the record from the database and increases the database's deleted-record statistics.

Alternatively, deletion can be performed through the box:

```dart
await todoBox.deleteById(item.generatedId);
```

## Reading All Todos

All records can be loaded using:

```dart
final todos = await todoBox.getAll();
```

The example sorts the records by date:

```dart
final list = await todoBox.getAll();

list.sort(
  (a, b) => b.date.compareTo(a.date),
);
```

## Database Events

DualStore provides events that can be used to react to database changes.

### Error Events

```dart
store.events.error.all.listen((event) {
  print('[Du Error Event]: $event');
});
```

### Box Events

```dart
store.events.box.all.listen((event) {
  print('Box Event: $event');

  print('lastId: ${store.state.lastId}');
  print('deletedCount: ${store.state.deletedCount}');
  print('deletedSize: ${store.state.deletedSize}');
});
```

### Open Events

```dart
store.events.open.listen((event) {
  checkCompact();
});
```

These events can be connected to Flutter's reactive widgets using `StreamBuilder`.

## Database State

The example displays three important database statistics:

```dart
store.state.lastId
store.state.deletedCount
store.state.deletedSize
```

### `lastId`

The last generated record ID.

### `deletedCount`

The number of deleted records currently tracked by the database.

### `deletedSize`

The amount of storage occupied by deleted records.

These values are useful for determining when database compaction should be performed.

## Database Compaction

Deleting records does not necessarily mean that the database file immediately becomes smaller.

The example detects whether deleted records exist:

```dart
void checkCompact() {
  if (store.state.deletedCount > 0) {
    if (!mounted) return;

    setState(() {
      needToCompact = true;
    });
  }
}
```

When deleted records exist, the UI displays a **DB Compact** button.

Compaction is performed with:

```dart
final result = await store.compact();

if (result.isErr) {
  print(result.unwrapError());
}
```

After successful compaction, the database can reclaim unused storage.

## Closing the Database

Always close the store when the Flutter widget is disposed:

```dart
@override
void dispose() {
  store.close();
  super.dispose();
}
```

This ensures that open resources are properly released.

## Complete Initialization Flow

The complete initialization flow is:

```dart
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

Future<void> init() async {
  await store.open('/home/thancoder/Documents/todo.du');
}
```

## Flutter Reactive UI

Because DualStore exposes streams for database events, the UI can react to changes using Flutter's `StreamBuilder`.

```dart
StreamBuilder(
  stream: todoBox.events.all,
  builder: (context, snapshot) {
    return FutureBuilder(
      future: todoBox.getAll(),
      builder: (context, snapshot) {
        final todos = snapshot.data ?? [];

        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];

            return Text(todo.title);
          },
        );
      },
    );
  },
)
```

This allows the UI to refresh when records are added, updated, or deleted.

## Storage Flow

The overall data flow is:

```text
Todo
  │
  ▼
TodoAdapter
  │
  ▼
DuBox<Todo>
  │
  ▼
DualStore
  │
  ▼
todo.du
```

When reading data, the process works in reverse:

```text
todo.du
  │
  ▼
DualStore
  │
  ▼
DuBox<Todo>
  │
  ▼
TodoAdapter
  │
  ▼
Todo
```

## Example UI

The example application provides:

```text
┌─────────────────────────────────────┐
│ Todo                    [DB Compact]│
├─────────────────────────────────────┤
│ LastId: 10                          │
│ deletedCount: 2                     │
│ deletedSize: 128                    │
├─────────────────────────────────────┤
│ ID: 10   Learn Dart       ☑         │
│ Date: 2026-09-27T...        [Delete]│
├─────────────────────────────────────┤
│ ID: 9    Build a Todo App  ☐        │
│ Date: 2026-09-27T...        [Delete]│
│                                     │
│                              [+]    │
└─────────────────────────────────────┘
```

## Why This Example?

This Todo application is intentionally simple. Its main purpose is to demonstrate the core DualStore workflow rather than building a feature-rich Todo application.

The example covers the most important operations:

```text
Register Adapter
       ↓
Open Store
       ↓
Get Typed Box
       ↓
Add / Update / Delete
       ↓
Listen to Events
       ↓
Monitor Database State
       ↓
Compact Database
       ↓
Close Store
```
## Dart Example
* [x] [Go Example List](#example-list)

```dart
 final st = DualStore();
  st.registerAdapter(UserAdapter());

  st.events.error.all.listen((event) {
    print('event: $event');
  });

  final openRes = await st.open('user.du');

  if (openRes.isErr) {
    print('open error: ${openRes.unwrapError()}');
    return;
  }
  /// db clean up
  //await st.compact();

  DuBox<User> box = st.getBox<User>();

  // await box.add(
  //   .new(name: 'two', age: 20, tags: ['one', 'two', 'three']),
  //   contentWriter: TextCompressContentWriter('i am compress text'),
  //   diskFlush: true,
  // );
  // await box.deleteById(1, diskFlush: false);
  // await box.deleteById(2, diskFlush: true);

  final list = await box.getAll();

  for (var user in list) {
    print('ID: ${user.generatedId} - user: $user');
    final con = await box.getContent<String>(user);
    if (con.isErr) {
      print('content Error: ${con.unwrapError()}');
      return;
    }
    print('content: ${con.unwrap()}');
  }
  print('opened: ${st.opened}');
  print('lastId: ${st.state.lastId}');
  print('deletedCount: ${st.state.deletedCount}');
  print('deletedSize: ${st.state.deletedSize}');

  await st.close();
```
## Flutter App Example

* [x] [Go Example List](#example-list)


```dart
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

```

## License

This example is provided as part of the DualStore project.
