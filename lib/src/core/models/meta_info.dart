// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dual_store/src/core/models/meta.dart';

class MetaInfo {
  int lastId;
  int deletedCount;
  int deletedSize;
  final Map<int, Meta> allMeta;
  MetaInfo({
    required this.lastId,
    required this.deletedCount,
    required this.deletedSize,
    required this.allMeta,
  });

  void add(Meta meta) {
    allMeta[meta.id] = meta;
    lastId = meta.id;
  }
}
