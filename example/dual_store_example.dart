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
  final st = Stopwatch()..start();

  final store = DualStore();
  store.registerAdapter(UserAdapter());
  await store.open('user.du');
  // store.openAsync('user.du');
  st.stop();
  print('opened time: ${st.elapsedMilliseconds}ms');

  final box = store.getBox<User>();

  box.getAllstream().listen((list) {
    print('stream list: $list');
  });

  // box.add(.new(name: 'four', age: 30));
  // box.add(.new(name: 'five', age: 30));

  // await box.delete((value) => value.age == 21);

  // print(await box.getAll());

  // print('onceInit: ${store.onceInit}');
  // print('opened: ${store.opened}');
  // print('lastId: ${store.state.lastId}');
  // print('deletedCount: ${store.state.deletedCount}');
  // print('deletedSize: ${store.state.deletedSize}');

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

class EmailAdapter extends IDuBinaryMetaAdapter<Email> {
  @override
  int get adapterId => 2;

  @override
  int parentId(Email value) {
    return value.userId;
  }

  @override
  Email fromMap(Map<String, dynamic> map) {
    return .fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(Email value) {
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

class Email extends IDuModel {
  final int userId;
  final String email;

  Email({required this.userId, required this.email});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email};
  }

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(userId: json['userId'], email: json['email']);
  }
}
