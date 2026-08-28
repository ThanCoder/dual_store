// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/binary_en_de/binary_storage_decoder.dart';
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

class BinaryMataReader implements IMetaReader<Map<String, dynamic>> {
  @override
  final Uint8List data;
  const BinaryMataReader(this.data);

  @override
  final DuMetaType metaType = .binary;

  @override
  Map<String, dynamic> decode() {
    return BinaryStorageDecoder(data).decodeAll();
  }
}
