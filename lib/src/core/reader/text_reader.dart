import 'dart:convert';

import 'package:dual_store/src/interfaces/i_reader.dart';

class TextReader implements IReader<String> {
  @override
  Future<String> readFromStream(Stream<List<int>> stream) async {
    final res = stream.transform(utf8.decoder);
    return await res.join();
  }
}
