import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/types.dart';

const int recordMetaFixedHeaderLength = 23;
const int recordContentFixedHeaderLength = 19;

/// Meta
///
///flag(1),id(8),parentId(8),adapterId(1),metaType(1),metaSize(4),metaData(N Bytes)
///
/// Content
///
/// contentType(1),
/// contentFlags(1)
/// contentSize(8),
/// contentData(n bytes)
///]
abstract class IMetaWriter {
  DuFlag get flag;
  int get parentId;
  int get adapterId;
  DuMetaType get metaType;
  Uint8List get data;
  int get size => data.length;
}

class JsonMetaWriter implements IMetaWriter {
  final Uint8List _data;
  JsonMetaWriter(
    Map<String, dynamic> map, {
    this.flag = DuFlag.active,
    required this.adapterId,
    required this.parentId,
  }) : _data = utf8.encode(jsonEncode(map));

  @override
  final int adapterId;

  @override
  final DuFlag flag;

  @override
  Uint8List get data => _data;

  @override
  DuMetaType get metaType => .json;

  @override
  final int parentId;

  @override
  int get size => _data.length;
}
