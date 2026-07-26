// ignore_for_file: unused_import, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/compresser/gzip_decoder_reader.dart';
import 'package:dual_store/src/core/compresser/gzip_encoder_writer.dart';
import 'package:dual_store/src/core/engine/core_engine.dart';
import 'package:dual_store/src/core/reader/text_reader.dart';
import 'package:dual_store/src/core/writer/file_record_writer.dart';
import 'package:dual_store/src/core/writer/text_record_writer.dart';

void main() async {
  final eng = await CoreEngine.open('test.dust');

  final text = File('LICENSE').readAsStringSync();

  // eng.write(TextRecordWriter(text: text, id: id))
  final rawStr = TextRecordWriter(text: text, id: 0);

  // ၂။ Raw data ရဲ့ byte size ကို စစ်မယ်
  final rawByteSize = await countBytes(rawStr.writeChunks());
  print('Raw bytes size: $rawByteSize bytes'); // Text length အစစ် ထွက်လာမယ်

  // ၃။ Gzip ချုပ်ပြီးသား size ကို စစ်မယ်
  final comStr = GzipEncoderWriter(rawStr);
  final gzipByteSize = await countBytes(comStr.writeChunks());
  print('Gzip bytes size: $gzipByteSize bytes');

  // de compress
  final compressedData = comStr.writeChunks();
  final deCom = GzipDecoderReader<String>(TextReader());

  print('data: ${await deCom.readFromStream(compressedData)}');

  await eng.close();
}

// 💡 Helper function: Stream ထဲက byte total length ကို ပေါင်းတွက်ပေးတာ
Future<int> countBytes(Stream<List<int>> stream) {
  return stream.fold<int>(0, (previous, chunk) => previous + chunk.length);
}
