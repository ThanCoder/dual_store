import 'dart:io';

import 'package:dual_store/src/interfaces/i_writer.dart';

class GzipEncoderWriter implements IWriter {
  final IWriter _writer;
  const GzipEncoderWriter(this._writer);
  @override
  Stream<List<int>> writeChunks() {
    return _writer.writeChunks().transform(gzip.encoder);
  }
}
