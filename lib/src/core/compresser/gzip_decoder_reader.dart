import 'dart:io';

import 'package:dual_store/src/interfaces/i_reader.dart';

class GzipDecoderReader<T> implements IReader<T> {
  final IReader<T> _reader;
  const GzipDecoderReader(this._reader);

  @override
  Future<T> readFromStream(Stream<List<int>> stream) {
    return _reader.readFromStream(stream.transform(gzip.decoder));
  }
}
