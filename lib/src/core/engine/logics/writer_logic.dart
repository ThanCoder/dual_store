import 'dart:typed_data';

import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';

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
  Result<bool, String> writeRecordSync(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
    required int id,
  }) {
    try {
      final headerOffset = ctx.writeRaf.positionSync();

      if (metaWriter.size != metaWriter.data.length) {
        throw StateError(
          'Meta size mismatch: '
          'expected=${contentWriter.size}, actual=${metaWriter.data.length}',
        );
      }

      final m = ByteData(recordMetaFixedHeaderLength);
      int offset = 0;

      m.setUint8(offset, metaWriter.flag.value);
      offset += 1;
      m.setUint64(offset, id, Endian.little);
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
      ctx.writeRaf.writeFromSync(m.buffer.asUint8List());
      ctx.writeRaf.writeFromSync(metaWriter.data);

      // write content header
      final c = ByteData(recordContentFixedHeaderLength);
      offset = 0;

      c.setUint8(offset, contentWriter.dataType.value);
      offset += 1;
      c.setUint8(offset, contentWriter.contentFlag.value);
      offset += 1;
      c.setUint64(offset, contentWriter.size, Endian.little);
      offset += 8;

      ctx.writeRaf.writeFromSync(c.buffer.asUint8List());

      final contentStartOffset = ctx.writeRaf.positionSync();

      // content မရှိဘူး
      if (contentWriter.size > 0) {
        // write content data
        final written = contentWriter.writeToSync(ctx.writeRaf);
        if (written != contentWriter.size) {
          throw StateError(
            'Content size mismatch: '
            'expected=${contentWriter.size}, actual=$written',
          );
        }
      }
      if (diskFlush) {
        ctx.writeRaf.flushSync();
      }
      final meta = Meta(
        flag: metaWriter.flag,
        id: id,
        parentId: metaWriter.parentId,
        adapterId: metaWriter.adapterId,
        metaType: metaWriter.metaType,
        metaSize: metaWriter.size,
        metaData: metaWriter.data,
        contentDataType: contentWriter.dataType,
        contentFlag: contentWriter.contentFlag,
        contentSize: contentWriter.size,
        headerOffset: headerOffset,
        contentStartOffset: contentStartOffset,
        totalSize:
            recordMetaFixedHeaderLength +
            recordContentFixedHeaderLength +
            metaWriter.size +
            contentWriter.size,
      );

      // update ctx
      ctx.allMeta[id] = meta;
      eventController.add(AddId(id));
      eventController.add(RecordWrited(meta));
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<bool, String>> writeRecord(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
    required int id,
  }) async {
    try {
      final headerOffset = ctx.writeRaf.positionSync();

      if (metaWriter.size != metaWriter.data.length) {
        throw StateError(
          'Meta size mismatch: '
          'expected=${contentWriter.size}, actual=${metaWriter.data.length}',
        );
      }

      final m = ByteData(recordMetaFixedHeaderLength);
      int offset = 0;

      m.setUint8(offset, metaWriter.flag.value);
      offset += 1;
      m.setUint64(offset, id, Endian.little);
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
      await ctx.writeRaf.writeFrom(m.buffer.asUint8List());
      await ctx.writeRaf.writeFrom(metaWriter.data);

      // write content header
      final c = ByteData(recordContentFixedHeaderLength);
      offset = 0;

      c.setUint8(offset, contentWriter.dataType.value);
      offset += 1;
      c.setUint8(offset, contentWriter.contentFlag.value);
      offset += 1;
      c.setUint64(offset, contentWriter.size, Endian.little);
      offset += 8;

      await ctx.writeRaf.writeFrom(c.buffer.asUint8List());

      final contentStartOffset = ctx.writeRaf.positionSync();

      // content မရှိဘူး
      if (contentWriter.size > 0) {
        // write content data
        final written = await contentWriter.writeTo(ctx.writeRaf);
        if (written != contentWriter.size) {
          throw StateError(
            'Content size mismatch: '
            'expected=${contentWriter.size}, actual=$written',
          );
        }
      }
      if (diskFlush) {
        ctx.writeRaf.flushSync();
      }

      final meta = Meta(
        flag: metaWriter.flag,
        id: id,
        parentId: metaWriter.parentId,
        adapterId: metaWriter.adapterId,
        metaType: metaWriter.metaType,
        metaSize: metaWriter.size,
        metaData: metaWriter.data,
        contentDataType: contentWriter.dataType,
        contentFlag: contentWriter.contentFlag,
        contentSize: contentWriter.size,
        headerOffset: headerOffset,
        contentStartOffset: contentStartOffset,
        totalSize:
            recordMetaFixedHeaderLength +
            recordContentFixedHeaderLength +
            metaWriter.size +
            contentWriter.size,
      );

      // update ctx
      ctx.allMeta[id] = meta;
      eventController.add(AddId(id));
      eventController.add(RecordWrited(meta));
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }
}
