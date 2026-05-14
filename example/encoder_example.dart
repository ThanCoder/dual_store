import 'dart:convert';
import 'dart:typed_data';

void main() {
  final encoder = Encoder();
  encoder.writeString(1, 'ThanCoder');
  encoder.writeInt(2, 22);
  encoder.writeDouble(3, 5.5);
  encoder.writeBool(4, true);

  print(encoder.finishedBytes);

  final decoder = Decoder(encoder.finishedBytes);
  print('Str: ${decoder.getString(1)}');
  print('Int: ${decoder.getInt(2, 9)}');
  print('Double: ${decoder.getDouble(3)}');
  print('Bool: ${decoder.getBool(4)}');
}

class Decoder {
  final Uint8List _data;
  int _offset = 0;
  final Map<int, dynamic> _decodedData = {};
  final void Function(String error)? onError;
  Decoder(this._data, {this.onError}) {
    decodeAll(onError);
  }

  void decodeAll(void Function(String error)? onError) {
    final buffer = _data.buffer.asByteData();

    try {
      while (_offset < _data.length) {
        // key
        final key = _data[_offset]; //read 1 byte
        _offset += 1;
        //type
        final type = _data[_offset]; //read 1 byte
        _offset += 1;
        if (type == Encoder.typeInt) {
          final val = buffer.getInt64(_offset, Endian.little);
          _offset += 8;
          // print('int: key: $key - val: $val');
          _decodedData[key] = val;
        } else if (type == Encoder.typeBool) {
          final val = buffer.getInt8(_offset) == 1 ? true : false;
          _offset += 1;
          // print('bool: key: $key - val: $val');
          _decodedData[key] = val;
        } else if (type == Encoder.typeDouble) {
          final val = buffer.getFloat64(_offset, Endian.little);
          // print('double: key: $key - val: $val');
          _decodedData[key] = val;
          _offset += 8;
        } else if (type == Encoder.typeString) {
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

class Encoder {
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

  void writeInt(int key, int value) {
    // write key
    _writeKey(key);
    // write type
    _builder.addByte(typeInt);

    final b = ByteData(8)..setInt64(0, value, Endian.little);
    _builder.add(b.buffer.asUint8List());
  }

  void writeDouble(int key, double value) {
    _writeKey(key);
    _builder.addByte(typeDouble);

    final b = ByteData(8)..setFloat64(0, value, Endian.little);
    _builder.add(b.buffer.asUint8List());
  }

  void writeBool(int key, bool value) {
    _writeKey(key);
    _builder.addByte(typeBool);
    _builder.addByte(value ? 1 : 0);
  }

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
