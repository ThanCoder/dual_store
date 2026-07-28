import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/types.dart';
import 'package:dual_store/src/store/adapter/i_du_model.dart';

abstract class IDuMetaAdapter<T extends IDuModel> {
  /// ### Record Query Id
  ///
  /// You Can use filter
  int getParentId(T value) => -1;

  /// ### Query Data Type
  ///
  /// I Will Used Ram Memory.
  ///
  DuMetaType get metaType => .json;

  /// ### Adapter Type
  ///
  /// I Will use Box
  int get adapterTypeId;

  /// ### T get id
  int getId(T value);

  Map<String, dynamic> toMeta(T value);
  T fromStorage(Map<String, dynamic> meta);

  /// Meta
  Uint8List encodeMeta(Map<String, dynamic> meta) {
    if (metaType == .json) {
      return Uint8List.fromList(utf8.encode(jsonEncode(meta)));
    }
    throw UnsupportedError('MetaType $metaType is not supported.');
  }

  Map<String, dynamic> decodeMeta(Uint8List bytes) {
    if (metaType == .json) {
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    }
    throw UnsupportedError('MetaType $metaType is not supported.');
  }
}
