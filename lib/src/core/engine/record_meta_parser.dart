import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/i_meta.dart';
import 'package:dual_store/src/interfaces/i_writer.dart';
import 'package:dual_store/src/interfaces/types.dart';

class RecordMetaParser {
  final RandomAccessFile _readRaf;
  RecordMetaParser(this._readRaf);

  //************Meta****************** */
  /// record[id(4),flag(1),parentId(4),adapterId(1),queryType(1),dataType(1),dataSize(4),data(n bytes)]
  Future<List<IMeta>> parseAll() async {
    final List<IMeta> list = [];
    final fileSize = _readRaf.lengthSync();
    _readRaf.setPositionSync(0);

    while (_readRaf.positionSync() < fileSize) {
      final recordStartPosition = _readRaf.positionSync();

      // Header Frame 16 bytes ကို ဖတ်ယူခြင်း
      final headerBytes = await _readRaf.read(
        BaseRecordWriter.recordHeaderSize,
      );
      if (headerBytes.length < BaseRecordWriter.recordHeaderSize) {
        // ဒေတာ မပြည့်စုံလျှင် ရပ်မည်
        break;
      }

      int internalOffset = 0;
      final byteData = ByteData.sublistView(headerBytes);

      final id = byteData.getInt32(internalOffset, BaseRecordWriter.endian);
      internalOffset += 4;
      final flag = headerBytes[internalOffset++];

      final parentId = byteData.getInt32(
        internalOffset,
        BaseRecordWriter.endian,
      );
      internalOffset += 4;
      final adapterId = headerBytes[internalOffset++];
      final queryType = headerBytes[internalOffset++];
      final dataType = headerBytes[internalOffset++];

      final dataSize = byteData.getInt32(
        internalOffset,
        BaseRecordWriter.endian,
      );
      internalOffset += dataSize;

      // active flag တွေကိုပဲ ရယူမယ်
      if (flag == RecordFlag.active.value) {
        list.add(
          RecordMeta(
            id: id,
            flag: RecordFlag.active,
            parentId: parentId,
            adapterId: adapterId,
            queryType: QueryType.fromValue(queryType),
            dataType: DataType.fromValue(dataType),
            recordOffset: recordStartPosition,
            dataSize: dataSize,
          ),
        );
      }

      // skip data
      final currentPos = _readRaf.positionSync();
      _readRaf.setPositionSync(currentPos + dataSize);
    }
    return list;
  }
}
