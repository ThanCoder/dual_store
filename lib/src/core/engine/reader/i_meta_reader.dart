import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/types.dart';

abstract interface class IMetaReader {
  DuMetaType get metaType;

  Uint8List get data;

  dynamic decode();
}

class JsonMetaReader extends IMetaReader {
  @override
  final Uint8List data;

  JsonMetaReader(this.data);

  @override
  DuMetaType get metaType => DuMetaType.json;

  @override
  Map<String, dynamic> decode() {
    return jsonDecode(utf8.decode(data));
  }
}
