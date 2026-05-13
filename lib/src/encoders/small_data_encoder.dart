import 'dart:convert';
import 'dart:typed_data';

/// Dual Small Data Encoder
class SmallDataEncoder {
  /// Dual Small Data Encoder
  SmallDataEncoder();

  final List<int> _buffer = [];

  void writeInt(int value) {
    var bData = ByteData(4);
    bData.setInt32(0, value);
    _buffer.addAll(bData.buffer.asUint8List());
  }

  void writeString(String value) {
    var bytes = utf8.encode(value);
    // Length ကို 4 bytes သိမ်းမယ် (စာသားအရှည်ကြီးတွေအတွက်)
    writeInt(bytes.length);
    _buffer.addAll(bytes);
  }

  void writeDouble(double value) {
    var bData = ByteData(8);
    bData.setFloat64(0, value);
    _buffer.addAll(bData.buffer.asUint8List());
  }

  void writeBool(bool value) {
    _buffer.add(value ? 1 : 0);
  }

  Uint8List get finishedBytes => Uint8List.fromList(_buffer);
}
