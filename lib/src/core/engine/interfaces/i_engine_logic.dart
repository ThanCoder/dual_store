import 'dart:io';

import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';

abstract class IEngineLogic {
  RandomAccessFile get writeRaf;
  RandomAccessFile get readRaf;

  void open(String path);
  void flush();
  void close();

  Future<void> writeRecord(IMetaWriter metaWriter, IContentWriter contentWriter);
}
