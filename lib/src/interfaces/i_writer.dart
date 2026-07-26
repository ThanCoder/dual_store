import 'dart:typed_data';

import 'package:dual_store/src/interfaces/types.dart';

abstract class IHeaderProvider {
  Uint8List getHeaderBytes();
  int get getSizePositionOffset;
  int? get totalDataSize;
}

/// record[id(4),flag(1),parentId(4),adapterId(1),queryType(1),dataType(1),dataSize(4),data(n bytes)]
abstract class IWriter {
  Stream<List<int>> writeChunks();
}

abstract class IRecordWriter implements IWriter, IHeaderProvider {}

abstract class BaseRecordWriter implements IRecordWriter {
  final int id;
  final RecordFlag flag;
  final int parentId;
  final int adapterId;
  final QueryType queryType;
  final DataType dataType;
  const BaseRecordWriter({
    required this.id,
    required this.flag,
    required this.parentId,
    required this.adapterId,
    required this.queryType,
    required this.dataType,
  });
  @override
  int get getSizePositionOffset => 12;

  static const endian = Endian.little;
  static const int recordHeaderSize = 16;

  /// record (16) -> [id(4),flag(1),parentId(4),adapterId(1),queryType(1),dataType(1),dataSize(4)]
  @override
  Uint8List getHeaderBytes() {
    final buffer = Uint8List(recordHeaderSize);
    final byteData = ByteData.sublistView(buffer);

    int offset = 0;

    byteData.setInt32(offset, id, endian);
    offset += 4;

    buffer[offset++] = flag.value;

    byteData.setInt32(offset, parentId, endian);
    offset += 4;

    buffer[offset++] = adapterId;
    buffer[offset++] = queryType.value;
    buffer[offset++] = dataType.value;

    // size ကို placeholder 0 ထားလိုက်တာ
    //engine က chunk ရေးပြီးမှ real size ပြန်ထည့်ပေးမှာ
    byteData.setInt32(offset, 0, endian);

    return buffer;
  }
}
