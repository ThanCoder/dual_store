import 'package:dual_store/dual_store.dart';

void main() async {
  final st = DualStore();
  st.registerAdapter(UserAdapter());

  st.events.error.all.listen((event) {
    print('event: $event');
  });

  // final openRes = await st.open('user.du');

  // if (openRes.isErr) {
  //   print('open error: ${openRes.unwrapError()}');
  //   return;
  // }
  print('opened: ${st.opened}');

  DuBox<User> box = st.getBox<User>();

  await box.add(
    .new(name: 'two', age: 20),
    contentWriter: TextCompressContentWriter('i am compress text'),
    diskFlush: true,
  );

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

  print('lastId: ${st.state.lastId}');
  print('deletedCount: ${st.state.deletedCount}');
  print('deletedSize: ${st.state.deletedSize}');

  await st.close();
}

class User extends IDuModel {
  final String name;
  final int age;
  User({required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'age': age};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(name: map['name'] as String, age: map['age'] as int);
  }

  @override
  String toString() => 'User(name: $name, age: $age)';
}

class UserAdapter extends IDuBinaryMetaAdapter<User> {
  @override
  User fromMap(Map<String, dynamic> map) {
    return User.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(User value) {
    return value.toMap();
  }

  @override
  int get adapterId => 1;
}
