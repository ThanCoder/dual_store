// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dual_store/src/core/models/meta.dart';

class MetaInfo extends Iterable<Meta> {
  int lastId = 0;
  int deletedCount = 0;
  int deletedSize = 0;
  Map<int, Meta> allMeta = {};

  MetaInfo({this.lastId = 0, this.deletedCount = 0, this.deletedSize = 0});

  void setEmpty() {
    lastId = 0;
    deletedCount = 0;
    deletedSize = 0;
    allMeta.clear();
  }

  void addMeta(Meta meta) {
    allMeta[meta.id] = meta;
    lastId = meta.id;
  }

  @override
  String toString() {
    return 'MetaInfo(lastId: $lastId, deletedCount: $deletedCount, deletedSize: $deletedSize)';
  }

  @override
  Iterator<Meta> get iterator => allMeta.values.iterator;
}
