import 'dart:typed_data';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/interfaces/types.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/core/models/meta_info.dart';

/// Meta
///
///flag(1),id(8),parentId(8),adapterId(1),metaType(1),metaSize(4),metaData(N Bytes)
///
/// Content
///
/// contentType(1),
/// contentFlags(1)
/// contentSize(8),
/// contentData(n bytes)
///]
///
mixin MetaInfoLogic on IEngineLogic {
  Future<MetaInfo> getMetaInfo() async {
    if (await readRaf.length() == 0) {
      return .empty();
    }

    int lastId = 0;
    int deletedCount = 0;
    int deletedSize = 0;
    final Map<int, Meta> allMeta = {};
    // skip header
    readRaf.setPositionSync(duHeaderFixedLength);

    final size = readRaf.lengthSync();
    // read header
    while (readRaf.positionSync() < size) {
      final headerOffset = readRaf.positionSync();

      final hBytes = readRaf.readSync(recordMetaFixedHeaderLength);
      assert(hBytes.length == recordMetaFixedHeaderLength);

      final d = ByteData.sublistView(hBytes);
      int offset = 0;

      final flag = DuFlag.fromValue(d.getUint8(offset));
      offset += 1;
      final id = d.getUint64(offset, Endian.little);
      offset += 8;
      final parentId = d.getUint64(offset, Endian.little);
      offset += 8;
      final adapterId = d.getUint8(offset);
      offset += 1;
      final metaType = DuMetaType.fromValue(d.getUint8(offset));
      offset += 1;
      final metaSize = d.getUint32(offset, Endian.little);
      offset += 4;
      // meta data
      final metaData = readRaf.readSync(metaSize);

      // content
      final cBytes = readRaf.readSync(recordContentFixedHeaderLength);

      if (hBytes.length != recordMetaFixedHeaderLength) {
        throw Exception("Invalid meta header");
      }

      final cd = ByteData.sublistView(cBytes);
      offset = 0;

      final contentDataType = DuContentDataType.fromValue(cd.getUint8(offset));
      offset += 1;
      final contentFlag = DuContentFlag.fromValue(cd.getUint8(offset));
      offset += 1;
      final contentSize = cd.getUint64(offset, Endian.little);
      offset += 8;

      final contentStartOffset = readRaf.positionSync();

      // skip content
      if (contentSize > 0) {
        final next = readRaf.positionSync() + contentSize;

        if (next > size) {
          throw Exception("Invalid content size");
        }

        readRaf.setPositionSync(next);
      }
      final totalSize =
          recordContentFixedHeaderLength +
          recordMetaFixedHeaderLength +
          metaSize +
          contentSize;
      // last id
      if (id > lastId) lastId = id;

      // check content
      if (flag == .deleted) {
        deletedSize += totalSize;
        deletedCount += 1;
        continue;
      }
      // add
      allMeta[id] = .new(
        flag: flag,
        id: id,
        parentId: parentId,
        adapterId: adapterId,
        metaType: metaType,
        metaSize: metaSize,
        metaData: metaData,
        contentDataType: contentDataType,
        contentFlag: contentFlag,
        contentSize: contentSize,
        headerOffset: headerOffset,
        contentStartOffset: contentStartOffset,
        totalSize: totalSize,
      );
    }

    return .new(
      lastId: lastId,
      deletedCount: deletedCount,
      deletedSize: deletedSize,
      allMeta: allMeta,
    );
  }
}
