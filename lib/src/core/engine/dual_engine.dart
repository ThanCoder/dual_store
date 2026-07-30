import 'dart:io';

import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_header_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/engine_io_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/meta_info_logic.dart';
import 'package:dual_store/src/core/engine/mixin_logics/writer_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';

class DualEngine extends IEngineLogic
    with EngineIoLogic, EngineHeaderLogic, WriterLogic, MetaInfoLogic {
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
