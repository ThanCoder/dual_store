# dual_store

A high-performance, memory-efficient binary storage engine for Dart and Flutter. It is designed to handle both small structured data and massive "Big Data" (up to 10GB+) without crashing your application.

## Features

- **Sequential Binary Mapping:** Ultra-fast data access using byte offsets.
- **Dual-Data Structure:**
  - **Small Data:** For metadata, user profiles, or settings (fixed/indexed).
  - **Big Data:** For large files, long strings, or JSON (handled via Streams).
- **Memory Safety:** Optimized for low-memory environments. Large files are streamed directly from disk.
- **64-bit Ready:** Supports file sizes beyond 4GB.

## Getting Started

### 1. Create an Adapter

To store your objects, you must create a `DualAdapter`.

**⚠️ IMPORTANT:** The order in which you write fields must be identical to the order in which you read them.

```dart
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
```
