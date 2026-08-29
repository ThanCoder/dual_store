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
  EngineContext({this.lastId = 0, this.deletedCount = 0, this.deletedSize = 0});

  bool opened = false;

  int get generatedId {
    lastId = lastId + 1;
    return lastId;
  }

  @override
  String toString() {
    return 'EngineContext(header: $header, lastId: $lastId, deletedCount: $deletedCount, deletedSize: $deletedSize)';
  }
}
