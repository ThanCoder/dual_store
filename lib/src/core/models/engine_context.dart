// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/meta.dart';

class EngineContext {
  late RandomAccessFile writeRaf;
  late RandomAccessFile readRaf;
  DuHeader header = .new(magic: 'dust');

  int lastId;
  int deletedCount;
  int deletedSize;
  Map<int, Meta> allMeta = {};
  Map<int, Set<int>> adapterMeta = {};
  EngineContext({this.lastId = 0, this.deletedCount = 0, this.deletedSize = 0});

  bool onceInit = false;
  bool opened = false;

  int get generatedId {
    lastId = lastId + 1;
    return lastId;
  }

  void clearState() {
    deletedCount = 0;
    deletedSize = 0;
    allMeta.clear();
    adapterMeta.clear();
  }
}
