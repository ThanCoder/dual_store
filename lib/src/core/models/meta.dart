// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/types.dart';

class Meta {
  final RecordFlag flag;
  final int id;
  final int parentId;
  final int adapterTypeId;
  final MetaType metaType;
  final int metaSize;
  final DataType dataType;
  final int dataSize;
  final Uint8List metaData;
  final int headerOffset;
  final int dataStartOffset;
  final int totalSize;
  const Meta({
    required this.flag,
    required this.id,
    required this.parentId,
    required this.adapterTypeId,
    required this.metaType,
    required this.metaSize,
    required this.dataType,
    required this.dataSize,
    required this.metaData,
    required this.headerOffset,
    required this.dataStartOffset,
    required this.totalSize,
  });

  @override
  String toString() {
    return 'Meta(flag: $flag, id: $id, parentId: $parentId, adapterTypeId: $adapterTypeId, metaType: $metaType, metaSize: $metaSize, dataType: $dataType, dataSize: $dataSize, headerOffset: $headerOffset, dataStartOffset: $dataStartOffset, totalSize: $totalSize)';
  }
}
