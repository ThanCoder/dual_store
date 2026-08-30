import 'dart:io';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/result_t.dart';

const int duHeaderLength = 6;

/// [magic(4),version(1),dbID(1)]
mixin EngineHeaderLogic on IEngineLogic {
  @override
  Result<DuHeader, String> readHeader(RandomAccessFile readRaf) {
    return DuHeaderIo.getHeaderSync(readRaf);
  }

  @override
  Result<bool, String> writeHeader(RandomAccessFile writeRaf, DuHeader header) {
    eventController.add(HeaderWrited());
    return DuHeaderIo.writeHeader(header, writeRaf);
  }
}
