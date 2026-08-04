import 'dart:io';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_header_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/meta_info_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/meta_remover_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/writer_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';

class DualEngine extends IEngineLogic
    with EngineHeaderLogic, WriterLogic, MetaInfoLogic, MetaRemoverLogic {
  DualEngine();

  @override
  late EngineContext ctx;

  @override
  Future<void> open(String path) async {
    final file = File(path);

    final exists = file.existsSync();

    final writeRaf = file.openSync(mode: FileMode.append);

    final readRaf = file.openSync(mode: FileMode.read);

    if (!exists || writeRaf.lengthSync() == 0) {
      writeHeader(writeRaf, const DuHeader(magic: 'dust'));

      writeRaf.flushSync();
    }

    final header = readHeader(readRaf);

    final metaInfo = await getMetaInfo(path);

    ctx = .new(
      writeRaf: writeRaf,
      readRaf: readRaf,
      header: header,
      allMeta: metaInfo.allMeta,
      lastId: metaInfo.lastId,
      deletedCount: metaInfo.deletedCount,
      deletedSize: metaInfo.deletedSize,
    );
  }

  @override
  void openSync(String path) {
    final file = File(path);

    final exists = file.existsSync();

    final writeRaf = file.openSync(mode: FileMode.append);
    final readRaf = file.openSync(mode: FileMode.read);

    if (!exists || writeRaf.lengthSync() == 0) {
      writeHeader(writeRaf, const DuHeader(magic: 'dust'));

      writeRaf.flushSync();
    }

    final header = readHeader(readRaf);
    final metaInfo = getMetaInfoSync(path);

    ctx = .new(
      writeRaf: writeRaf,
      readRaf: readRaf,
      header: header,
      allMeta: metaInfo.allMeta,
      lastId: metaInfo.lastId,
      deletedCount: metaInfo.deletedCount,
      deletedSize: metaInfo.deletedSize,
    );
  }

  @override
  void close() {
    ctx.readRaf.closeSync();
    ctx.writeRaf.closeSync();
  }

  @override
  void flush() {
    ctx.writeRaf.flushSync();
  }

  /// ### Read Header
  static Future<DuHeader?> getHeader(
    String path, {
    bool showErrorLog = false,
  }) async {
    DuHeader? header;
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
  static DuHeader? getHeaderAsync(String path, {bool showErrorLog = false}) {
    DuHeader? header;
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
