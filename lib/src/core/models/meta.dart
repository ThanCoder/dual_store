// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/types.dart';

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
class Meta {
  final DuFlag flag;
  final int id;
  final int parentId;
  final int adapterId;
  final DuMetaType metaType;
  final int metaSize;
  final Uint8List metaData;
  // content
  final DuContentDataType contentDataType;
  final DuContentFlag contentFlag;
  final int contentSize;
  final int contentStartOffset;
  
  final int headerOffset;
  final int totalSize;
  const Meta({
    required this.flag,
    required this.id,
    required this.parentId,
    required this.adapterId,
    required this.metaType,
    required this.metaSize,
    required this.metaData,
    required this.contentDataType,
    required this.contentFlag,
    required this.contentSize,
    required this.headerOffset,
    required this.contentStartOffset,
    required this.totalSize,
  });

  @override
  String toString() {
    return 'Meta(flag: $flag, id: $id, parentId: $parentId, adapterId: $adapterId, metaType: $metaType, metaSize: $metaSize contentDataType: $contentDataType, contentFlag: $contentFlag, contentSize: $contentSize, headerOffset: $headerOffset, totalSize: $totalSize)';
  }
}
