import 'dart:typed_data';
import 'dart:convert';

import 'package:dual_store/dual_store.dart';

/// Dual Small Data Decoder
class SmallDataDecoder {
  final Uint8List _data;
  int _offset = 0;
  final Map<int, dynamic> _decodedData = {};
  final void Function(String error)? onError;

  Map<int, dynamic> get decodedData => _decodedData;

  /// Decord All
  SmallDataDecoder(this._data, {this.onError}) {
    _decodeAll(onError);
  }

  void _decodeAll(void Function(String error)? onError) {
    final buffer = _data.buffer.asByteData();

    try {
      while (_offset < _data.length) {
        // key
        final key = _data[_offset]; //read 1 byte
        _offset += 1;
        //type
        final type = _data[_offset]; //read 1 byte
        _offset += 1;
        if (type == SmallDataEncoder.typeInt) {
          final val = buffer.getInt64(_offset, Endian.little);
          _offset += 8;
          // print('int: key: $key - val: $val');
          _decodedData[key] = val;
        } else if (type == SmallDataEncoder.typeBool) {
          final val = buffer.getInt8(_offset) == 1 ? true : false;
          _offset += 1;
          // print('bool: key: $key - val: $val');
          _decodedData[key] = val;
        } else if (type == SmallDataEncoder.typeDouble) {
          final val = buffer.getFloat64(_offset, Endian.little);
          // print('double: key: $key - val: $val');
          _decodedData[key] = val;
          _offset += 8;
        } else if (type == SmallDataEncoder.typeString) {
          final strLength = buffer.getInt32(_offset, Endian.little);
          _offset += 4;

          final strBytes = _data.sublist(_offset, _offset + strLength);
          final val = utf8.decode(strBytes);
          // print('String: key: $key - val: $val');
          _decodedData[key] = val;
          _offset += strLength;
        }
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  int getInt(int key, [int defVal = 0]) {
    final val = _decodedData[key];
    return (val is int) ? val : defVal;
  }

  double getDouble(int key, [double defVal = 0.0]) {
    final val = _decodedData[key];
    return (val is double) ? val : defVal;
  }

  bool getBool(int key, [bool defVal = false]) {
    final val = _decodedData[key];
    return (val is bool) ? val : defVal;
  }

  String getString(int key, [String defVal = '']) {
    final val = _decodedData[key];
    return (val is String) ? val : defVal;
  }
}
