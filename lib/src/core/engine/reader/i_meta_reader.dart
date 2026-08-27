import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/types.dart';

abstract interface class IMetaReader<R> {
  const IMetaReader();

  DuMetaType get metaType;
  Uint8List get data;
  R decode();
}

class JsonMetaReader implements IMetaReader<Map<String, dynamic>> {
  @override
  final Uint8List data;
  const JsonMetaReader(this.data);

  @override
  DuMetaType get metaType => DuMetaType.json;

  @override
  Map<String, dynamic> decode() {
    return jsonDecode(utf8.decode(data));
  }
}
