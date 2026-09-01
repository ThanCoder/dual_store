part of '../dual_store_base.dart';

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
abstract class IDuModel {
  IDuModel();
  late Meta _meta;

  late DuBox _box;

  /// db created id
  int get generatedId => _meta.id;

  ///
  /// supported: `TextRawContentReader`,`TextCompressContentReader`
  ///
  Future<Result<R, String>> getContent<R>() async {
    return await _box.getContent<R>(this);
  }
}
