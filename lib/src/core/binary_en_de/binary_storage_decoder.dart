import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/binary_en_de/binary_storage_encoder.dart';

class BinaryStorageDecoder {
  final Uint8List _data;
  const BinaryStorageDecoder(this._data);

  Map<String, dynamic> decodeAll() {
    Map<String, dynamic> decodedData = {};
    int offset = 0;
    final data = ByteData.sublistView(_data);

    final count = data.getUint32(offset, Endian.little);
    offset += 4;

    for (var i = 0; i < count; i++) {
      final keyLen = data.getUint32(offset, Endian.little);
      offset += 4;

      final key = utf8.decode(_data.sublist(offset, offset + keyLen));
      offset += keyLen;
      // print('key: $key');

      final type = data.getUint8(offset);
      offset += 1;

      dynamic value;
      switch (type) {
        case BinaryStorageEncoder.typeBool:
          value = data.getUint8(offset) == 1;
          offset += 1;
        case BinaryStorageEncoder.typeInt:
          value = data.getInt64(offset, Endian.little);
          offset += 8;
        case BinaryStorageEncoder.typeDouble:
          value = data.getFloat64(offset, Endian.little);
          offset += 8;
        case BinaryStorageEncoder.typeString:
          final len = data.getUint32(offset, Endian.little);
          offset += 4;

          value = utf8.decode(_data.sublist(offset, offset + len));
          offset += len;
        default:
          throw FormatException('Unknown type: $type');
      }

      decodedData[key] = value;
    }

    return decodedData;
  }
}
