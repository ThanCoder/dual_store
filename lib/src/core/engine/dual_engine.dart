import 'dart:io';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/logics/engine_io_logic.dart';
import 'package:dual_store/src/core/engine/logics/content_reader_logic.dart';
import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/logics/engine_header_logic.dart';
import 'package:dual_store/src/core/engine/logics/meta_info_logic.dart';
import 'package:dual_store/src/core/engine/logics/meta_remover_logic.dart';
import 'package:dual_store/src/core/engine/logics/writer_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/result_t.dart';

class DualEngine extends IEngineLogic
    with
        EngineHeaderLogic,
        EngineIoLogic,
        WriterLogic,
        MetaInfoLogic,
        MetaRemoverLogic,
        ContentReaderLogic {
  DualEngine();

  @override
  final EngineContext ctx = .new();

  //*********************Static Methods******************************** */

  /// ### Read Header
  static Future<Result<DuHeader, String>> getHeader(
    String path, {
    bool showErrorLog = false,
  }) async {
    try {
      final raf = await File(path).open(mode: FileMode.read);
      final header = await DuHeaderIo.getHeader(raf);
      raf.closeSync();
      return header;
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// ### Read Header Sync
  static Result<DuHeader, String> getHeaderAsync(
    String path, {
    bool showErrorLog = false,
  }) {
    try {
      final raf = File(path).openSync(mode: FileMode.read);
      final header = DuHeaderIo.getHeaderSync(raf);
      raf.closeSync();
      return header;
    } catch (e) {
      return Err(e.toString());
    }
  }
}
