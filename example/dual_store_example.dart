// ignore_for_file: unused_import, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/du_record.dart';
import 'package:dual_store/src/core/engine/dual_engine.dart';

void main() async {
  final du = DualEngine();
  du.open('store.du');

  // print(du.readHeader());

  // final meta = utf8.encode('i am meta 2');
  // final data = utf8.encode('i am content 2');

  // du.writeRecord(
  //   DuRecord(
  //     id: 2,
  //     metaSize: meta.length,
  //     dataSize: data.length,
  //     metaData: meta,
  //     data: data,
  //   ),
  // );
  // du.flush();

  for (var meta in du.getAllMeta()) {
    print(meta);
  }

  du.close();
}
