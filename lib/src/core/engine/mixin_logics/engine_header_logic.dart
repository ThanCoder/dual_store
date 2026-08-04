import 'dart:io';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';

const int duHeaderLength = 6;

/// [magic(4),version(1),dbID(1)]
mixin EngineHeaderLogic on IEngineLogic {
  DuHeader readHeader(RandomAccessFile readRaf) {
    return DuHeaderIo.getHeaderSync(readRaf);
  }

  void writeHeader(RandomAccessFile writeRaf, DuHeader header) {
    DuHeaderIo.writeHeader(header, writeRaf);
  }
}
