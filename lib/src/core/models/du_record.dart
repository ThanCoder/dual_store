// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/du_content.dart';
import 'package:dual_store/src/interfaces/types.dart';

const int duMetaHeaderLength = 24;
const int duContentHeaderLength = 28;

/// [ all bytes(24)
///
///### Fixed Header
/// flag(1),recordType(1),id(8),parentId(8),adapterTypeId(1),
/// mataType(1),metaSize(4),
///
/// ### N Bytes
///
/// metaData(n bytes),
/// data(n bytes)
/// ]
class DuMetaRecord {
  final int id;
  final int parentId;
  final int adapterTypeId;
  final DuMetaType metaType;
  final int metaSize;
  final Uint8List metaData;
  const DuMetaRecord({
    required this.id,
    required this.parentId,
    required this.adapterTypeId,
    required this.metaType,
    required this.metaSize,
    required this.metaData,
  });
}

/// ### Content Fixed Header
///
///  meta all bytes(28)
///
/// flag(1),recordType(1),id(8),metaId(8),contentFlags(1)
/// contentType(1),contentSize(8),
/// contentData(n bytes)
///
class DuContentRecord {
  final int id;
  final int metaId;
  final DuContentFlag contentFlags;
  final DuContent duContent;
  const DuContentRecord({
    required this.id,
    required this.metaId,
    required this.contentFlags,
    required this.duContent,
  });
}
