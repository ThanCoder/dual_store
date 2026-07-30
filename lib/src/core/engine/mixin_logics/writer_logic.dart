import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';

///header
///[
///
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
mixin WriterLogic on IEngineLogic {
  @override
  Future<void> writeRecord(
    IMetaWriter metaWriter,
    IContentWriter contentWriter,
  ) async {
    final m = ByteData(recordMetaFixedHeaderLength);
    int offset = 0;

    m.setUint8(offset, metaWriter.flag.value);
    offset += 1;
    m.setUint64(offset, metaWriter.id, Endian.little);
    offset += 8;
    m.setUint64(offset, metaWriter.parentId, Endian.little);
    offset += 8;
    m.setUint8(offset, metaWriter.adapterId);
    offset += 1;
    m.setUint8(offset, metaWriter.metaType.value);
    offset += 1;
    m.setUint32(offset, metaWriter.size, Endian.little);
    offset += 4;

    // write meta data
    await writeRaf.writeFrom(m.buffer.asUint8List());
    await writeRaf.writeFrom(metaWriter.data);

    // write content header
    final c = ByteData(recordContentFixedHeaderLength);
    offset = 0;

    c.setUint8(offset, contentWriter.dataType.value);
    offset += 1;
    c.setUint8(offset, contentWriter.contentFlag.value);
    offset += 1;
    c.setUint64(offset, contentWriter.size, Endian.little);
    offset += 8;

    await writeRaf.writeFrom(c.buffer.asUint8List());
    // content မရှိဘူး
    if (contentWriter.size == 0) {
      return;
    }
    // write content data
    await contentWriter.writeTo(writeRaf);
  }
}
