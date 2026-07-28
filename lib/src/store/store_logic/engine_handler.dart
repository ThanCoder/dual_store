part of '../du_store.dart';

mixin EngineHandler on IDuStore {
  /// ### Last Generated Id
  int get lastId {
    return _metaInfo.lastId;
  }

  /// ### Deleted Count
  int get deletedCount {
    return _metaInfo.deletedCount;
  }

  /// ### Deleted Size
  int get deletedSize {
    return _metaInfo.deletedSize;
  }
}
