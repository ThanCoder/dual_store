// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: unused_import, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/binary_en_de/binary_storage_decoder.dart';
import 'package:dual_store/src/core/binary_en_de/binary_storage_encoder.dart';
import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/engine/interfaces/types.dart';
import 'package:dual_store/src/core/engine/reader/i_content_reader.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';

void main() async {
  final en = BinaryStorageEncoder();
  en.put('id', 1);
  en.put('deleted-id', -1);
  en.put('volume', 1.0);
  en.put('volume-del', -1.0);
  en.put('name', 'thancoder');
  en.put('isMan', true);
  // en.put('isMan', en);
  final bytes = en.toBytes();
  print('bytes: $bytes');

  final de = BinaryStorageDecoder(bytes);
  print(de.decodeAll());

  // final eng = DualEngine();
  // await eng.open('store.du');
  // eng.openSync('store.du');

  // await eng.writeRecord(
  //   JsonMetaWriter({'name': 'three'}, adapterId: 1, parentId: -1),
  //   TextRawContentWriter('i am text content three'),
  //   id: eng.ctx.generatedId,
  // );
  // // eng.removeMeta(eng.ctx.allMeta[2]!);

  // final info = eng.ctx;
  // print('info: $info \n\n');

  // if (info.allMeta.values.isNotEmpty) {
  //   final meta = info.allMeta.values.last;
  //   final text = eng.readContentExactSync(TextRawContentReader(meta));
  //   print('text: ${text.unwrap()}');
  // }

  // for (var meta in info.allMeta.values) {
  //   print('Meta: $meta');
  // }
}
