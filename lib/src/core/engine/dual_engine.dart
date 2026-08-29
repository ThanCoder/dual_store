import 'dart:io';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/mixin_logics/content_reader_logic.dart';
import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_header_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/meta_info_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/meta_remover_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/writer_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/result_t.dart';

class DualEngine extends IEngineLogic
    with
        EngineHeaderLogic,
        WriterLogic,
        MetaInfoLogic,
        MetaRemoverLogic,
        ContentReaderLogic {
  DualEngine();

  @override
  EngineContext ctx = .new();
  @override
  late RandomAccessFile readRaf;
  @override
  late RandomAccessFile writeRaf;

  @override
  Future<Result<bool, String>> reload() async {
    close();
    return await open(readRaf.path);
  }

  @override
  Result<bool, String> reloadSync() {
    close();
    return openSync(readRaf.path);
  }

  @override
  Future<Result<bool, String>> open(String path) async {
    try {
      ctx.opened = false;

      final file = File(path);

      final exists = file.existsSync();

      writeRaf = file.openSync(mode: FileMode.append);

      readRaf = file.openSync(mode: FileMode.read);

      if (!exists || writeRaf.lengthSync() == 0) {
        writeHeader(writeRaf, const DuHeader(magic: 'dust'));
        await writeRaf.flush();
      }

      final headerRes = readHeader(readRaf);
      if (headerRes.isErr) {
        return Err(headerRes.unwrapError());
      }
      final metaInfoRes = await getMetaInfo(path);
      if (metaInfoRes.isErr) {
        return Err(metaInfoRes.unwrapError());
      }
      final metaInfo = metaInfoRes.unwrap();

      ctx.writeRaf = writeRaf;
      ctx.readRaf = readRaf;
      ctx.header = headerRes.unwrap();
      ctx.allMeta = metaInfo.allMeta;
      ctx.lastId = metaInfo.lastId;
      ctx.deletedCount = metaInfo.deletedCount;
      ctx.deletedSize = metaInfo.deletedSize;
      ctx.opened = true;
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Result<bool, String> openSync(String path) {
    try {
      ctx.opened = false;

      final file = File(path);

      final exists = file.existsSync();

      writeRaf = file.openSync(mode: FileMode.append);
      readRaf = file.openSync(mode: FileMode.read);

      if (!exists || writeRaf.lengthSync() == 0) {
        writeHeader(writeRaf, const DuHeader(magic: 'dust'));

        writeRaf.flushSync();
      }

      final headerRes = readHeader(readRaf);
      if (headerRes.isErr) {
        return Err(headerRes.unwrapError());
      }
      final metaInfoRes = getMetaInfoSync(path);
      if (metaInfoRes.isErr) {
        return Err(metaInfoRes.unwrapError());
      }
      final metaInfo = metaInfoRes.unwrap();

      ctx.writeRaf = writeRaf;
      ctx.readRaf = readRaf;
      ctx.header = headerRes.unwrap();
      ctx.allMeta = metaInfo.allMeta;
      ctx.lastId = metaInfo.lastId;
      ctx.deletedCount = metaInfo.deletedCount;
      ctx.deletedSize = metaInfo.deletedSize;
      ctx.opened = true;
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Result<bool, String> close() {
    try {
      ctx.readRaf.closeSync();
      ctx.writeRaf.closeSync();
      ctx.opened = false;
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Result<bool, String> flush() {
    try {
      ctx.writeRaf.flushSync();
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }
  //*********************Static Methods******************************** */

  /// ### Read Header
  static Future<Result<DuHeader, String>> getHeader(
    String path, {
    bool showErrorLog = false,
  }) async {
    late Result<DuHeader, String> header;
    try {
      final raf = await File(path).open(mode: FileMode.read);
      header = await DuHeaderIo.getHeader(raf);
      raf.closeSync();
    } catch (e) {
      if (showErrorLog) {
        print('[DualEngine:getHeader]: $e');
      }
    }
    return header;
  }

  /// ### Read Header Sync
  static Result<DuHeader, String> getHeaderAsync(
    String path, {
    bool showErrorLog = false,
  }) {
    late Result<DuHeader, String> header;
    try {
      final raf = File(path).openSync(mode: FileMode.read);
      header = DuHeaderIo.getHeaderSync(raf);
      raf.closeSync();
    } catch (e) {
      if (showErrorLog) {
        print('[DualEngine:getHeader]: $e');
      }
    }
    return header;
  }
}
