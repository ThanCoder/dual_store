// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dual_store/src/core/models/content_info.dart';
import 'package:dual_store/src/core/models/meta.dart';

class MetaInfo {
  int lastId;
  int deletedCount;
  int deletedSize;
  final Map<int, Meta> allMeta;
  final Map<int, ContentInfo> allContent;
  MetaInfo({
    required this.lastId,
    required this.deletedCount,
    required this.deletedSize,
    required this.allMeta,
    required this.allContent,
  });

  void addMeta(Meta meta) {
    allMeta[meta.id] = meta;
    lastId = meta.id;
  }

  void addContent(ContentInfo info) {
    allContent[info.id] = info;
    lastId = info.id;
  }
}
