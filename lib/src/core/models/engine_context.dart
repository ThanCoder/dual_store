// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/meta.dart';

class EngineContext {
  RandomAccessFile writeRaf;
  RandomAccessFile readRaf;
  DuHeader header;

  int lastId;
  int deletedCount;
  int deletedSize;
  Map<int, Meta> allMeta;
  EngineContext({
    required this.writeRaf,
    required this.readRaf,
    required this.header,
    this.lastId = 0,
    this.deletedCount = 0,
    this.deletedSize = 0,
    required this.allMeta,
  });

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
