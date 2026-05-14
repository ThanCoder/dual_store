// ignore_for_file: unused_local_variable

import 'dart:typed_data';

import 'package:dual_store/dual_store.dart';

void main() async {
  final db = DualStore();
  db.registerAdapterNotExists<User>(UserAdapter());
  db.registerAdapterNotExists<UserContent>(UserContentAdapter());

  db.registerAdapterNotExists<User>(UserAdapter());
  db.registerAdapterNotExists<UserContent>(UserContentAdapter());

  await db.open('dual.db');

  final box = db.getBox<User>();
  final contentBox = db.getBox<UserContent>();

  // await contentBox.addWithBigDataString(
  //   UserContent(userId: 1),
  //   bigString: 'i am big string two',
  // );

  // await db.compact();

  // await contentBox.deleteAll();
  // await box.deleteAll();
  for (var content in await contentBox.getAll()) {
    print(content);
    final data = await contentBox.readBigDataAsString(content);
    print('data: $data');
  }

  print('lastIndex: ${db.lastIndex}');
  print('deletedCount: ${db.deletedCount}');
  print('deletedSize: ${db.deletedSize}');

  await db.close();
}

class UserAdapter extends DualAdapter<User> {
  @override
  int get adapterTypeId => 1;

  @override
  int getId(User value) {
    return value.id;
  }

  @override
  User fromSmallData(SmallDataDecoder decoder) {
    return User(
      id: decoder.getInt(1), //generated auto id
      name: decoder.getString(2),
      age: decoder.getInt(3),
    );
  }

  @override
  Uint8List toSmallData(
    User value,
    int generatedAutoId,
    SmallDataEncoder encoder,
  ) {
    encoder.writeInt(1, generatedAutoId); //write auto id
    encoder.writeString(2, value.name);
    encoder.writeInt(3, value.age);
    return encoder.finishedBytes;
  }
}

class User extends DualModel {
  final int id; //auto id
  final String name;
  final int age;
  User({this.id = -1, required this.name, required this.age});

  @override
  String toString() => 'User(id: $id, name: $name, age: $age)';
}

// content
class UserContentAdapter extends DualAdapter<UserContent> {
  @override
  int get adapterTypeId => 2;

  @override
  int getParentId(UserContent value) {
    return value.userId;
  }

  @override
  int getId(UserContent value) {
    return value.id;
  }

  @override
  UserContent fromSmallData(SmallDataDecoder decoder) {
    return UserContent(id: decoder.getInt(1), userId: decoder.getInt(2));
  }

  @override
  Uint8List toSmallData(
    UserContent value,
    int generatedAutoId,
    SmallDataEncoder encoder,
  ) {
    encoder.writeInt(1, generatedAutoId);
    encoder.writeInt(2, value.userId);
    return encoder.finishedBytes;
  }

  @override
  BigDataType get bigDataType => BigDataType.stringText;
}

class UserContent extends DualModel {
  final int id;
  final int userId;
  UserContent({this.id = -1, required this.userId});

  @override
  String toString() => 'UserContent(id: $id, userId: $userId)';
}
