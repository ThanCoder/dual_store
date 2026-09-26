import 'dart:convert';
import 'dart:typed_data';

class BinaryStorageEncoder {
  // Value Type Markers
  static const int typeInt = 1;
  static const int typeDouble = 2;
  static const int typeBool = 3;
  static const int typeString = 4;
  static const int typeList = 5;
  static const int typeMap = 6;

  final _map = <String, dynamic>{};

  /// Supports:
  /// int, double, bool, String,
  /// List, `Map<String, dynamic>`
  BinaryStorageEncoder putMap(Map<String, dynamic> map) {
    map.forEach(put);
    return this;
  }

  /// Supports:
  /// int, double, bool, String,
  /// List, `Map<String, dynamic>`
  void put(String key, dynamic value) {
    _checkSupported(value);
    _map[key] = value;
  }

  void _checkSupported(dynamic value) {
    if (value is int || value is double || value is bool || value is String) {
      return;
    }

    if (value is List) {
      for (final item in value) {
        _checkSupported(item);
      }
      return;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw UnsupportedError(
            'Map key must be String, got `${entry.key.runtimeType}`',
          );
        }

        _checkSupported(entry.value);
      }
      return;
    }

    throw UnsupportedError('Unsupported type: `${value.runtimeType}`');
  }

  Uint8List toBytes() {
    final builder = BytesBuilder();

    // Entry count
    _writeUint32(builder, _map.length);

    for (final entry in _map.entries) {
      _writeString(builder, entry.key);
      _writeValue(builder, entry.value);
    }

    return builder.toBytes();
  }

  void _writeValue(BytesBuilder builder, dynamic value) {
    if (value is bool) {
      builder.addByte(typeBool);
      builder.addByte(value ? 1 : 0);
      return;
    }

    if (value is int) {
      builder.addByte(typeInt);

      final data = ByteData(8)..setInt64(0, value, Endian.little);

      builder.add(data.buffer.asUint8List());
      return;
    }

    if (value is double) {
      builder.addByte(typeDouble);

      final data = ByteData(8)..setFloat64(0, value, Endian.little);

      builder.add(data.buffer.asUint8List());
      return;
    }

    if (value is String) {
      builder.addByte(typeString);
      _writeString(builder, value);
      return;
    }

    if (value is List) {
      builder.addByte(typeList);

      // List length
      _writeUint32(builder, value.length);

      // Recursive values
      for (final item in value) {
        _writeValue(builder, item);
      }

      return;
    }

    if (value is Map) {
      builder.addByte(typeMap);

      // Map length
      _writeUint32(builder, value.length);

      for (final entry in value.entries) {
        _writeString(builder, entry.key as String);
        _writeValue(builder, entry.value);
      }

      return;
    }

    throw UnsupportedError('Unsupported type: `${value.runtimeType}`');
  }

  void _writeString(BytesBuilder builder, String value) {
    final bytes = utf8.encode(value);

    _writeUint32(builder, bytes.length);
    builder.add(bytes);
  }

  void _writeUint32(BytesBuilder builder, int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.little);

    builder.add(data.buffer.asUint8List());
  }
}
