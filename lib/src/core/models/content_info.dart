// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dual_store/src/interfaces/types.dart';

/// ### Content Fixed Header
///
///  meta all bytes(28)
///
/// flag(1),recordType(1),id(8),metaId(8),contentFlags(1)
/// contentType(1),contentSize(8),
/// contentData(n bytes)
///
class ContentInfo {
  final DuFlag flag;
  final int id;
  final int metaId;
  final DuContentFlag contentFlags;
  final DuContentDataType contentType;
  final int contentSize;
  final int headerOffset;
  final int totalSize;
  const ContentInfo({
    required this.flag,
    required this.id,
    required this.metaId,
    required this.contentFlags,
    required this.contentType,
    required this.contentSize,
    required this.headerOffset,
    required this.totalSize,
  });

  @override
  String toString() {
    return 'ContentInfo(flag: $flag, id: $id, metaId: $metaId, contentFlags: $contentFlags, contentType: $contentType, contentSize: $contentSize, headerOffset: $headerOffset, totalSize: $totalSize)';
  }
}
