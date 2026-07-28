import 'dart:typed_data';

import 'package:dual_store/src/core/models/content_info.dart';
import 'package:dual_store/src/core/models/du_record.dart';
import 'package:dual_store/src/core/engine/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_header.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/core/models/meta_info.dart';
import 'package:dual_store/src/interfaces/types.dart';

/// [ all bytes(24)
///
///### Fixed Header
/// flag(1),recordType(1),id(8),parentId(8),adapterTypeId(1),
/// mataType(1),metaSize(4),
///
/// ### N Bytes
///
/// metaData(n bytes),
/// data(n bytes)
/// ]
mixin MetaReader on IEngineLogic {
  /// ### Read Meta Info List
  MetaInfo getMetaInfo() {
    final Map<int, Meta> allMeta = {};
    final Map<int, ContentInfo> allContent = {};
    int lastId = 0;
    int deletedCount = 0;
    int deletedSize = 0;

    readRaf.setPositionSync(duHeaderLength);

    while (readRaf.positionSync() < readRaf.lengthSync()) {
      final headerOffset = readRaf.positionSync();

      final headerBytes = readRaf.readSync(duMetaHeaderLength);

      if (headerBytes.length != duMetaHeaderLength) {
        throw Exception('[RecordReader:readRecord] Header read failed.');
      }

      final data = ByteData.sublistView(headerBytes);
      int offset = 0;

      final flag = DuFlag.fromValue(data.getUint8(offset));
      offset += 1;
      final recordType = RecordType.fromValue(data.getUint8(offset));
      offset += 1;

      // meta
      if (recordType == .meta) {
        final id = data.getUint64(offset, Endian.little);
        offset += 8;
        final parentId = data.getUint64(offset, Endian.little);
        offset += 8;
        final adapterTypeId = data.getInt8(offset);
        offset += 1;
        final metaType = DuMetaType.fromValue(data.getInt8(offset));
        offset += 1;
        final metaSize = data.getUint32(offset, Endian.little);
        offset += 4;
      }
      // content file
      else if (recordType == .content) {}
    }

    return MetaInfo(
      lastId: lastId,
      deletedCount: deletedCount,
      deletedSize: deletedSize,
      allMeta: allMeta,
      allContent: allContent,
    );
  }
}
