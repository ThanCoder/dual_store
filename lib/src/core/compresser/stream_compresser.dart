import 'dart:async';
import 'dart:io';

class CompressStreamTransformer
    extends StreamTransformerBase<List<int>, List<int>> {
  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    return stream.transform(gzip.encoder);
  }
}

class DecompressStreamTransformer
    extends StreamTransformerBase<List<int>, List<int>> {
  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    return stream.transform(gzip.decoder);
  }
}
