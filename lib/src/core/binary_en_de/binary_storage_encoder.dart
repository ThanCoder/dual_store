import 'dart:convert';
import 'dart:typed_data';

class BinaryStorageEncoder {
  // Value Type Markers
  static const int typeInt = 1;
  static const int typeDouble = 2;
  static const int typeBool = 3;
  static const int typeString = 4;

  final _map = <String, dynamic>{};

  /// Supports: int, double, bool, String
  void put(String key, dynamic value) {
    if (value is! int &&
        value is! bool &&
        value is! double &&
        value is! String) {
      throw UnsupportedError('Unsupported type: `${value.runtimeType}`');
    }
    _map[key] = value;
  }

  /// Format:
  ///
  /// [key length: uint32]
  /// [key bytes]
  /// [type: uint8]
  /// [value]
  Uint8List toBytes() {
    final builder = BytesBuilder();

    // Entry count
    final count = ByteData(4)..setUint32(0, _map.length, Endian.little);
    builder.add(count.buffer.asUint8List());

    for (var m in _map.entries) {
      _writeStringValue(builder, m.key);
      final type = m.value;

      if (type is bool) {
        builder.addByte(typeBool);
        final val = m.value as bool;
        builder.addByte(val ? 1 : 0);
      }
      //int
      else if (type is int) {
        builder.addByte(typeInt);
        final b = ByteData(8)..setInt64(0, m.value, Endian.little);
        builder.add(b.buffer.asUint8List());
      }
      // double
      else if (type is double) {
        builder.addByte(typeDouble);
        final b = ByteData(8)..setFloat64(0, m.value, Endian.little);
        builder.add(b.buffer.asUint8List());
      }
      // string
      else if (type is String) {
        builder.addByte(typeString);
        _writeStringValue(builder, m.value);
      }
    }
    return builder.toBytes();
  }

  void _writeStringValue(BytesBuilder builder, String value) {
    final bytes = utf8.encode(value);
    final len = ByteData(4)..setUint32(0, bytes.length, Endian.little);
    builder.add(len.buffer.asUint8List());
    builder.add(bytes);
  }
}
