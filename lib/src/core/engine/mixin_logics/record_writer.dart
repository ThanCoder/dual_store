import 'dart:typed_data';

import 'package:dual_store/src/core/du_record.dart';
import 'package:dual_store/src/core/engine/i_engine_logic.dart';

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
  void writeRecord(DuRecord rec) {
    // final headerOffset = writeRaf.lengthSync();

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

    final b = BytesBuilder(copy: false);
    b.add(data.buffer.asUint8List());
    // add data
    b.add(rec.metaData);
    b.add(rec.data);

    writeRaf.writeFromSync(b.takeBytes());
  }
}
