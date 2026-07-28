// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/types.dart';

const int duRecordHeaderLength = 32;

/// [ all bytes(32)
///
///### Fixed Header
/// flag(1),id(8),parentId(8),adapterTypeId(1),
/// mataType(1),metaSize(4)
/// dataType(1),dataSize(8),
///
/// ### N Bytes
///
/// metaData(n bytes),
/// data(n bytes)
/// ]
class DuRecord {
  final RecordFlag flag;
  final int id;
  final int parentId;
  final int adapterTypeId;
  final MetaType metaType;
  final DataType dataType;
  final int metaSize;
  final Uint8List metaData;
  final int dataSize;
  final Uint8List data;
  const DuRecord({
    this.flag = RecordFlag.active,
    required this.id,
    this.parentId = -1,
    this.adapterTypeId = -1,
    this.metaType = MetaType.text,
    this.dataType = DataType.text,
    required this.metaSize,
    required this.metaData,
    required this.dataSize,
    required this.data,
  });
}
