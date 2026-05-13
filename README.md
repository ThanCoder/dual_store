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
  int get adapterTypId => 1; // Unique ID for this type

  @override
  User fromSmallData(Uint8List data) {
    final decoder = SmallDataDecoder(data);
    return User(
      id: decoder.readInt(),     // Position 1
      name: decoder.readString(), // Position 2
      age: decoder.readInt(),    // Position 3
    );
  }

  @override
  Uint8List toSmallData(User value) {
    final data = SmallDataEncoder();
    data.writeInt(value.id);      // Position 1
    data.writeString(value.name);  // Position 2
    data.writeInt(value.age);     // Position 3
    return data.finishedBytes;
  }

  @override
  BigDataType get bigDataType => BigDataType.stringText;

  @override
  int getBigDataSize(User value) => utf8.encode(value.bio).length;

  @override
  Stream<List<int>> getBigDataStream(User value) =>
      Stream.value(utf8.encode(value.bio));
}
```
