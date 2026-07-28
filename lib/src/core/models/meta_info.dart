// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dual_store/src/core/models/meta.dart';

class MetaInfo {
  final int lastId;
  final int deletedCount;
  final int deletedSize;
  final Map<int, Meta> allMeta;
  const MetaInfo({
    required this.lastId,
    required this.deletedCount,
    required this.deletedSize,
    required this.allMeta,
  });

  @override
  String toString() {
    return 'MetaInfo(lastId: $lastId, deletedCount: $deletedCount, deletedSize: $deletedSize)';
  }
}
