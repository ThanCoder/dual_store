// ignore_for_file: unused_local_variable

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/binary_en_de/binary_storage_decoder.dart';
import 'package:dual_store/src/core/binary_en_de/binary_storage_encoder.dart';

void main() async {
  testDB();
}

void testEncoder() async {
  final encoder = BinaryStorageEncoder();

  encoder.putMap({
    'name': 'Than',
    'age': 25,
    'rating': 4.5,
    'enabled': true,

    'numbers': [1, 2, 3, 4],

    'mixed': [10, 3.14, true, 'Hello'],

    'users': [
      {'id': 1, 'name': 'A', 'active': true},
      {'id': 2, 'name': 'B', 'active': false},
    ],
  });

  final bytes = encoder.toBytes();
  // print(bytes);

  final result = BinaryStorageDecoder(bytes).decodeAll();

  print(result['name']); // Than
  print(result['age']); // 25
  print(result['numbers']); // [1, 2, 3]
  print(result['mixed']); // [10, 3.14, true, hello]

  print(result['users']);
  // {id: 100, name: Than, tags: [flutter, dart]}
}

void testDB() async {
  final store = DualStore();
  store.registerAdapter(UserAdapter());

  store.events.all.listen((event) {
    print('event: $event');
  });

  await store.open('user.du');

  final box = store.getBox<User>();

  box.getSearchBox(searchType: .linear).getAllStream().listen((users) {
    print('users: $users');
  });

  // await box.add(.new(name: 'one', age: 21));
  // await box.add(.new(name: 'two', age: 21));
  // await box.add(.new(name: 'three', age: 21));
  // await box.add(.new(name: 'four', age: 12));
  await box.deleteById(4);

  // print(await box.getAll());

  print('onceInit: ${store.onceInit}');
  print('opened: ${store.opened}');
  print('lastId: ${store.state.lastId}');
  print('deletedCount: ${store.state.deletedCount}');
  print('deletedSize: ${store.state.deletedSize}');

  await store.close();
}

class UserAdapter extends IDuBinaryMetaAdapter<User> {
  @override
  int get adapterId => 1;

  @override
  User fromMap(Map<String, dynamic> map) {
    return User.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(User value) {
    return value.toJson();
  }
}

class User extends IDuModel {
  final String name;
  final int age;
  User({required this.name, required this.age});

  @override
  String toString() => '''User(ID: $generatedId, name: $name, age: $age)''';

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], age: json['age']);
  }
}
