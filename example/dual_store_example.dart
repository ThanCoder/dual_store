import 'package:dual_store/dual_store.dart';

void main() async {
  final st = DualStore();

  await st.open('user.du');

  st.registerAdapter(UserAdapter());

  DuBox<User> box = st.getBox<User>();

  // await box.update(
  //   1,
  //   value: .new(name: 'thancoder', age: 18),
  //   contentWriter: TextCompressContentWriter('i am compressed text body updated'),
  // );
  // await box.deleteById(2);

  for (var user in await box.getAll()) {
    print('ID: ${user.generatedId}- user: $user');
    final con = await box.getContent(user);
    if (con.isErr) {
      print('content Error: ${con.unwrapError()}');
      return;
    }
    print('content: ${con.unwrap()}');
  }

  print('lastId: ${st.lastId}');
  print('deletedCount: ${st.deletedCount}');
  print('deletedSize: ${st.deletedSize}');

  st.close();
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

class UserAdapter extends IDuJsonMetaAdapter<User> {
  @override
  User fromMap(Map<String, dynamic> map) {
    return User.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(User value) {
    return value.toMap();
  }
}
