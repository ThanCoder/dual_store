// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: unused_import, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/engine/interfaces/types.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';

void main() async {
  final eng = DualEngine();
  await eng.open('store.du');
  // eng.openSync('store.du');

  // await eng.writeRecord(
  //   JsonMetaWriter({'name': 'three'}, adapterId: 1, id: 3, parentId: -1),
  //   TextContentWriter('i am text content three'),
  // );
  eng.removeMeta(eng.ctx.allMeta[2]!);

  final info = eng.ctx;
  print('info: $info \n\n');

  for (var meta in info.allMeta.values) {
    print('Meta: $meta');
  }
}
