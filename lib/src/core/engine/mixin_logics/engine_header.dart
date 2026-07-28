import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/i_engine_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';

const int duHeaderLength = 6;

/// [magic(4),version(1),dbID(1)]
mixin EngineHeader on IEngineLogic {
  DuHeader getHeader() {
    return DuHeaderIo.getHeaderSync(readRaf);
  }

  void writeHeader(DuHeader header) {
    DuHeaderIo.writeHeader(header, writeRaf);
  }
}
