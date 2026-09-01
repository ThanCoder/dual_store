import 'dart:typed_data';

import 'package:dual_store/src/core/engine/reader/i_meta_reader.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/store/dual_store_base.dart';

sealed class IDuMetaAdapter<T extends IDuModel> {
  /// 1-255
  int get adapterId;

  ///
  int parentId(T value) => 0;

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T value);

  ///return JsonMetaWriter(toMap(value));
  IMetaWriter toMetaWriter(T value);

  ///return JsonMetaReader(rawData);
  IMetaReader<Map<String, dynamic>> toMetaReader(Uint8List rawData);
}

/// Example
///
/// ```dart
/// class User extends IDuModel {
///   final String name;
///   final int age;
///   User({required this.name, required this.age});
///
///   Map<String, dynamic> toMap() {
///     return <String, dynamic>{'name': name, 'age': age};
///   }
///
///   factory User.fromMap(Map<String, dynamic> map) {
///     return User(name: map['name'] as String, age: map['age'] as int);
///   }
///
///   @override
///   String toString() => 'User(name: $name, age: $age)';
/// }
///
/// class UserAdapter extends IDuJsonMetaAdapter<User> {
///   @override
///   User fromMap(Map<String, dynamic> map) {
///     return User.fromMap(map);
///   }
///
///   @override
///   Map<String, dynamic> toMap(User value) {
///     return value.toMap();
///   }
/// }
///
/// ```
abstract class IDuJsonMetaAdapter<T extends IDuModel>
    extends IDuMetaAdapter<T> {
  @override
  IMetaWriter toMetaWriter(T value) {
    return JsonMetaWriter(
      toMap(value),
      adapterId: adapterId,
      parentId: parentId(value),
    );
  }

  @override
  IMetaReader<Map<String, dynamic>> toMetaReader(Uint8List rawData) {
    return JsonMetaReader(rawData);
  }
}

/// Example
///
/// ```dart
/// class User extends IDuModel {
///   final String name;
///   final int age;
///   User({required this.name, required this.age});
///
///   Map<String, dynamic> toMap() {
///     return <String, dynamic>{'name': name, 'age': age};
///   }
///
///   factory User.fromMap(Map<String, dynamic> map) {
///     return User(name: map['name'] as String, age: map['age'] as int);
///   }
///
///   @override
///   String toString() => 'User(name: $name, age: $age)';
/// }
///
/// class UserAdapter extends IDuBinaryMetaAdapter<User> {
///   @override
///   User fromMap(Map<String, dynamic> map) {
///     return User.fromMap(map);
///   }
///
///   @override
///   Map<String, dynamic> toMap(User value) {
///     return value.toMap();
///   }
/// }
///
/// ```
abstract class IDuBinaryMetaAdapter<T extends IDuModel>
    extends IDuMetaAdapter<T> {
  @override
  IMetaWriter toMetaWriter(T value) {
    return BinaryMetaWriter(
      toMap(value),
      adapterId: adapterId,
      parentId: parentId(value),
    );
  }

  @override
  IMetaReader<Map<String, dynamic>> toMetaReader(Uint8List rawData) {
    return BinaryMataReader(rawData);
  }
}
