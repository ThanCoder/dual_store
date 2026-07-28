import 'dart:io';

import 'package:dual_store/src/core/engine/i_engine_logic.dart';

mixin EngineIo on IEngineLogic {
  set writeRaf(RandomAccessFile raf);
  set readRaf(RandomAccessFile raf);
}
