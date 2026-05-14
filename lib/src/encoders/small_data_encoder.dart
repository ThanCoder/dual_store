import 'dart:convert';
import 'dart:typed_data';

/// Dual Small Data Encoder
class SmallDataEncoder {
  // Value Type Markers
  static const int typeInt = 1;
  static const int typeDouble = 2;
  static const int typeBool = 3;
  static const int typeString = 4;

  final _builder = BytesBuilder();

  void _writeKey(int key) {
    if (key < 0 || key > 255) {
      throw Exception("Key must be between 0 and 255");
    }
    _builder.addByte(key);
  }

  /// Write Int With Key
  void writeInt(int key, int value) {
    // write key
    _writeKey(key);
    // write type
    _builder.addByte(typeInt);

    final b = ByteData(8)..setInt64(0, value, Endian.little);
    _builder.add(b.buffer.asUint8List());
  }

  /// Write Double With Key
  void writeDouble(int key, double value) {
    _writeKey(key);
    _builder.addByte(typeDouble);

    final b = ByteData(8)..setFloat64(0, value, Endian.little);
    _builder.add(b.buffer.asUint8List());
  }

  /// Write Boolean With Key
  void writeBool(int key, bool value) {
    _writeKey(key);
    _builder.addByte(typeBool);
    _builder.addByte(value ? 1 : 0);
  }

  /// Write String With Key
  void writeString(int key, String value) {
    _writeKey(key);
    _builder.addByte(typeString);

    final stringBytes = utf8.encode(value);
    final b = ByteData(4)..setInt32(0, stringBytes.length, Endian.little);
    // set string length
    _builder.add(b.buffer.asUint8List());
    //set string value
    _builder.add(stringBytes);
  }

  Uint8List get finishedBytes => _builder.toBytes();
}
