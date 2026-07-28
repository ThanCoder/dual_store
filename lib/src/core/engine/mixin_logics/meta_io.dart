import 'dart:typed_data';

import 'package:dual_store/src/core/du_record.dart';
import 'package:dual_store/src/core/engine/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_header.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/core/models/meta_info.dart';
import 'package:dual_store/src/interfaces/types.dart';

/// [ all bytes(32)
///
///### Fixed Header
/// flag(1),id(8),parentId(8),adapterTypeId(1),
/// mataType(1),metaSize(4)
/// dataType(1),dataSize(8),
///
/// ### N Bytes
///
/// metaData(n bytes),
/// data(n bytes)
/// ]
mixin MetaIo on IEngineLogic {
  /// ### Delete Mark
  bool deleteMark(Meta meta) {
    final lastPos = writeRaf.positionSync();
    // go meta pos
    writeRaf.setPositionSync(meta.headerOffset);
    writeRaf.writeByteSync(RecordFlag.deleted.value);

    writeRaf.setPositionSync(lastPos);
    return true;
  }

  /// ### Read Data From Meta
  Uint8List getDataFromMeta(Meta meta) {
    readRaf.setPositionSync(meta.dataStartOffset);
    final data = readRaf.readSync(meta.dataSize);
    assert(data.length == meta.dataSize);

    return data;
  }

  /// ### Read Meta Info List
  MetaInfo getMetaInfo() {
    Map<int, Meta> allMeta = {};
    int lastId = 0;
    int deletedCount = 0;
    int deletedSize = 0;

    readRaf.setPositionSync(duHeaderLength);

    while (readRaf.positionSync() < readRaf.lengthSync()) {
      final headerOffset = readRaf.positionSync();

      final headerBytes = readRaf.readSync(duRecordHeaderLength);

      if (headerBytes.length != duRecordHeaderLength) {
        throw Exception('[RecordReader:readRecord] Header read failed.');
      }

      final data = ByteData.sublistView(headerBytes);
      int offset = 0;

      final flag = RecordFlag.fromValue(data.getUint8(offset));
      offset += 1;
      final id = data.getUint64(offset, Endian.little);
      offset += 8;
      final parentId = data.getUint64(offset, Endian.little);
      offset += 8;
      final adapterTypeId = data.getInt8(offset);
      offset += 1;
      final metaType = MetaType.fromValue(data.getInt8(offset));
      offset += 1;
      final metaSize = data.getUint32(offset, Endian.little);
      offset += 4;
      final dataType = DataType.fromValue(data.getInt8(offset));
      offset += 1;
      final dataSize = data.getUint64(offset, Endian.little);
      offset += 8;

      assert(offset == duRecordHeaderLength);

      // meta data
      final metaData = readRaf.readSync(metaSize);
      if (metaData.length != metaSize) {
        throw Exception('MetaData corrupted');
      }

      final dataStartPos = readRaf.positionSync();
      final nextPos = dataStartPos + dataSize;
      // skip data
      if (nextPos > readRaf.lengthSync()) {
        throw Exception('Data section corrupted');
      }
      readRaf.setPositionSync(nextPos);
      // record total size
      final totalSize = duRecordHeaderLength + metaSize + dataSize;

      // check flag
      if (flag == .deleted) {
        deletedCount++;
        deletedSize += totalSize;
        continue;
      }
      if (id > lastId) lastId = id;
      // add meta
      allMeta[id] = Meta(
        flag: flag,
        id: id,
        parentId: parentId,
        adapterTypeId: adapterTypeId,
        metaType: metaType,
        metaSize: metaSize,
        dataType: dataType,
        dataSize: dataSize,
        metaData: metaData,
        headerOffset: headerOffset,
        dataStartOffset: dataStartPos,
        totalSize: totalSize,
      );
    }

    return MetaInfo(
      lastId: lastId,
      deletedCount: deletedCount,
      deletedSize: deletedSize,
      allMeta: allMeta,
    );
  }
}
