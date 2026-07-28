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

  // final meta = utf8.encode('i am meta 1');
  // final data = utf8.encode('i am content 1');

  // du.writeRecord(
  //   DuRecord(
  //     id: 1,
  //     metaSize: meta.length,
  //     dataSize: data.length,
  //     metaData: meta,
  //     data: data,
  //   ),
  // );
  // du.flush();

  // du.deleteMark(du.getMetaInfo().allMeta[1]!);

  print('before: ${du.getMetaInfo()}');

  // du.compact(du.getHeader(), du.getMetaInfo().allMeta);

  print('after: ${du.getMetaInfo()}');

  // du.deleteMark(info.allMeta[1]!);

  du.close();
}
