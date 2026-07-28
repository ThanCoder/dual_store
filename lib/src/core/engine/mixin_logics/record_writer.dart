import 'dart:typed_data';

import 'package:dual_store/src/core/models/du_record.dart';
import 'package:dual_store/src/core/engine/i_engine_logic.dart';
import 'package:dual_store/src/core/models/meta.dart';

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
mixin RecordWriter on IEngineLogic {
  Meta writeRecord(DuRecord rec) {
    assert(rec.metaData.length == rec.metaSize);
    assert(rec.data.length == rec.dataSize);

    final headerOffset = writeRaf.lengthSync();

    final data = ByteData(duRecordHeaderLength);
    int offset = 0;

    data.setUint8(offset, rec.flag.value);
    offset += 1;
    data.setUint64(offset, rec.id, Endian.little);
    offset += 8;
    data.setUint64(offset, rec.parentId, Endian.little);
    offset += 8;
    data.setInt8(offset, rec.adapterTypeId);
    offset += 1;
    data.setInt8(offset, rec.metaType.value);
    offset += 1;
    data.setUint32(offset, rec.metaSize, Endian.little);
    offset += 4;
    data.setInt8(offset, rec.dataType.value);
    offset += 1;
    data.setUint64(offset, rec.dataSize, Endian.little);
    offset += 8;

    writeRaf.writeFromSync(data.buffer.asUint8List());
    writeRaf.writeFromSync(rec.metaData);
    writeRaf.writeFromSync(rec.data);

    // end pos
    final dataStartOffset = headerOffset + duRecordHeaderLength + rec.metaSize;

    return Meta(
      flag: rec.flag,
      id: rec.id,
      parentId: rec.parentId,
      adapterTypeId: rec.adapterTypeId,
      metaType: rec.metaType,
      metaSize: rec.metaSize,
      dataType: rec.dataType,
      dataSize: rec.dataSize,
      metaData: rec.metaData,
      headerOffset: headerOffset,
      dataStartOffset: dataStartOffset,
      totalSize: duRecordHeaderLength + rec.metaSize + rec.dataSize,
    );
  }
}
