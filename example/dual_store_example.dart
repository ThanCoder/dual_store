// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: unused_import, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/models/du_record.dart';
import 'package:dual_store/src/interfaces/types.dart';

void main() async {
  final du = DuStore();

  await du.open('store.du');
  print('header: ${du.getHeader()}');

  du.registerAdapterNotExists(UserAdapter());
  du.registerAdapterNotExists(UserAdapter());

  final box = du.getBox<User>();

  await box.add(User(title: 'i am user one'));
  // await box.add(User(title: 'i am user two'));
  // await box.add(User(title: 'i am user three'));

  print(await box.getAll());

  await du.close();
}

class UserAdapter extends IDuAdapter<User> {
  @override
  int get adapterTypeId => 1;

  @override
  int getId(User value) {
    return value.generatedId;
  }

  @override
  Map<String, dynamic> toMeta(User value) {
    return value.toMap();
  }

  @override
  User fromStorage(Map<String, dynamic> meta) {
    return User.fromMap(meta);
  }
}

class User extends IDuModel {
  @override
  late int generatedId;

  final String title;
  User({required this.title});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(title: map['title'] as String);
  }

  @override
  String toString() => 'Generated Id:$generatedId -  User(title: $title)';
}
