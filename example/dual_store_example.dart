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

  await st.compact();

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
}

class User extends IDuModel {
  final String name;
  final int age;
  final List<String> tags;
  User({required this.name, required this.age, required this.tags});

  @override
  String toString() => '''User(name: $name, age: $age, tags: $tags)''';

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'tags': tags};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
      tags: List<String>.from(json['tags']),
    );
  }
}

class UserAdapter extends IDuBinaryMetaAdapter<User> {
  @override
  User fromMap(Map<String, dynamic> map) {
    return User.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(User value) {
    return value.toJson();
  }

  @override
  int get adapterId => 1;
}
