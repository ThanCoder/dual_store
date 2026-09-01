import 'package:dual_store/dual_store.dart';

void main() async {
  final st = DualStore();
  st.registerAdapter(UserAdapter());

  st.events.all.listen((event) {
    print('event: $event');
  });

  final openRes = await st.open('user.du');

  if (openRes.isErr) {
    print('open error: ${openRes.unwrapError()}');
    return;
  }

  DuBox<User> box = st.getBox<User>();

  // box.getAll()

  // await box.add(
  //   .new(name: 'thancoder', age: 30),
  //   contentWriter: TextRawContentWriter('i am raw content text'),
  // );
  //

  final res = await box.getOne((val) => val.age == 18);
  if (res.isOk) {
    print('res: ${res.unwrap()}');
  }

  // final user = await box.getById(2);
  // if (user.isErr) {
  //   print('Err: ${user.unwrapError()}');
  //   return;
  // }
  // print('user: ${user.unwrap()}');

  // await box.update(
  //   1,
  //   value: .new(name: 'thancoder', age: 18),
  //   contentWriter: TextCompressContentWriter('i am compressed text body updated'),
  // );
  // await box.deleteById(2);
  final listRes = await box.getAll();
  if (listRes.isErr) {
    print(listRes.unwrapError());
    return;
  }
  for (var user in listRes.unwrap()) {
    print('ID: ${user.generatedId}- user: $user');
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
  int get adapterId => 0;
}
