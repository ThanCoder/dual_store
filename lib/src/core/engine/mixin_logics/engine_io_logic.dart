import 'dart:io';

import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';

mixin EngineIoLogic on IEngineLogic {
  set writeRaf(RandomAccessFile raf);
  set readRaf(RandomAccessFile raf);
}
