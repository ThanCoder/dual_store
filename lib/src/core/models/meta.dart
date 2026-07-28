// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/types.dart';

/// ### Meta Fixed Header
///
/// [ meta all bytes(23)
///
/// flag(1),id(8),parentId(8),adapterTypeId(1),
/// mataType(1),metaSize(4)
/// metaData(n bytes),
/// ]
class Meta {
  final DuFlag flag;
  final int id;
  final int parentId;
  final int adapterTypeId;
  final DuMetaType metaType;
  final int metaSize;
  final Uint8List metaData;
  final int headerOffset;
  final int totalSize;
  const Meta({
    required this.flag,
    required this.id,
    required this.parentId,
    required this.adapterTypeId,
    required this.metaType,
    required this.metaSize,
    required this.metaData,
    required this.headerOffset,
    required this.totalSize,
  });

  @override
  String toString() {
    return 'Meta(flag: $flag, id: $id, parentId: $parentId, adapterTypeId: $adapterTypeId, metaType: $metaType, metaSize: $metaSize, metaData: $metaData, headerOffset: $headerOffset, totalSize: $totalSize)';
  }
}
