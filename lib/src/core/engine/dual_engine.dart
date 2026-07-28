import 'dart:io';

import 'package:dual_store/src/core/engine/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/compact_io.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_header.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_io.dart';
import 'package:dual_store/src/core/engine/mixin_logics/meta_io.dart';
import 'package:dual_store/src/core/engine/mixin_logics/record_writer.dart';
import 'package:dual_store/src/core/models/du_header.dart';

class DualEngine extends IEngineLogic
    with EngineIo, EngineHeader, RecordWriter, MetaIo, CompactIo {
  @override
  late RandomAccessFile writeRaf;
  @override
  late RandomAccessFile readRaf;
  DualEngine();

  @override
  void open(String path) {
    final file = File(path);

    final exists = file.existsSync();

    writeRaf = file.openSync(mode: FileMode.append);
    readRaf = file.openSync(mode: FileMode.read);

    if (!exists || file.lengthSync() == 0) {
      writeHeader(const DuHeader(magic: 'dust'));
    }
  }

  @override
  void close() {
    readRaf.closeSync();
    writeRaf.closeSync();
  }

  @override
  void flush() {
    writeRaf.flushSync();
  }
}
