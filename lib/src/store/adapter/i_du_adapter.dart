import 'dart:typed_data';

import 'package:dual_store/src/core/engine/reader/i_meta_reader.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/store/dual_store_base.dart';

sealed class IDuMetaAdapter<T extends IDuModel> {
  int get adapterId => 0;
  int get parentId => 0;

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T value);

  ///return JsonMetaWriter(toMap(value));
  IMetaWriter toMetaWriter(T value);

  ///return JsonMetaReader(rawData);
  IMetaReader<Map<String, dynamic>> toMetaReader(Uint8List rawData);
}

abstract class IDuJsonMetaAdapter<T extends IDuModel>
    extends IDuMetaAdapter<T> {
  @override
  IMetaWriter toMetaWriter(T value) {
    return JsonMetaWriter(toMap(value));
  }

  @override
  IMetaReader<Map<String, dynamic>> toMetaReader(Uint8List rawData) {
    return JsonMetaReader(rawData);
  }
}

abstract class IDuBinaryMetaAdapter<T extends IDuModel>
    extends IDuMetaAdapter<T> {
  @override
  IMetaWriter toMetaWriter(T value) {
    return BinaryMetaWriter(toMap(value));
  }

  @override
  IMetaReader<Map<String, dynamic>> toMetaReader(Uint8List rawData) {
    return BinaryMataReader(rawData);
  }
}
