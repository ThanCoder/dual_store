import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/binary_en_de/binary_storage_encoder.dart';

class BinaryStorageDecoder {
  final Uint8List _data;

  const BinaryStorageDecoder(this._data);

  Map<String, dynamic> decodeAll() {
    final data = ByteData.sublistView(_data);
    var offset = 0;

    final count = _readUint32(data, offset);
    offset += 4;

    final decodedData = <String, dynamic>{};

    for (var i = 0; i < count; i++) {
      final keyResult = _readString(data, offset);
      final key = keyResult.value;
      offset = keyResult.offset;

      final valueResult = _readValue(data, offset);
      offset = valueResult.offset;

      decodedData[key] = valueResult.value;
    }

    return decodedData;
  }

  _DecodedValue<dynamic> _readValue(ByteData data, int offset) {
    final type = data.getUint8(offset);
    offset += 1;

    switch (type) {
      case BinaryStorageEncoder.typeBool:
        final value = data.getUint8(offset) == 1;

        return _DecodedValue(value, offset + 1);

      case BinaryStorageEncoder.typeInt:
        final value = data.getInt64(offset, Endian.little);

        return _DecodedValue(value, offset + 8);

      case BinaryStorageEncoder.typeDouble:
        final value = data.getFloat64(offset, Endian.little);

        return _DecodedValue(value, offset + 8);

      case BinaryStorageEncoder.typeString:
        final result = _readString(data, offset);

        return _DecodedValue(result.value, result.offset);

      case BinaryStorageEncoder.typeList:
        return _readList(data, offset);

      case BinaryStorageEncoder.typeMap:
        return _readMap(data, offset);

      default:
        throw FormatException('Unknown type: $type');
    }
  }

  _DecodedValue<List<dynamic>> _readList(ByteData data, int offset) {
    final count = _readUint32(data, offset);
    offset += 4;

    final list = <dynamic>[];

    for (var i = 0; i < count; i++) {
      final result = _readValue(data, offset);

      list.add(result.value);
      offset = result.offset;
    }

    return _DecodedValue(list, offset);
  }

  _DecodedValue<Map<String, dynamic>> _readMap(ByteData data, int offset) {
    final count = _readUint32(data, offset);
    offset += 4;

    final map = <String, dynamic>{};

    for (var i = 0; i < count; i++) {
      final keyResult = _readString(data, offset);

      final key = keyResult.value;
      offset = keyResult.offset;

      final valueResult = _readValue(data, offset);

      map[key] = valueResult.value;
      offset = valueResult.offset;
    }

    return _DecodedValue(map, offset);
  }

  _DecodedValue<String> _readString(ByteData data, int offset) {
    final length = _readUint32(data, offset);
    offset += 4;

    final value = utf8.decode(_data.sublist(offset, offset + length));

    return _DecodedValue(value, offset + length);
  }

  int _readUint32(ByteData data, int offset) {
    return data.getUint32(offset, Endian.little);
  }
}

class _DecodedValue<T> {
  final T value;
  final int offset;

  const _DecodedValue(this.value, this.offset);
}
