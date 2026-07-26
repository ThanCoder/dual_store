// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:dual_store/src/core/engine/record_meta_parser.dart';
import 'package:dual_store/src/core/engine/record_stream_reader.dart';
import 'package:dual_store/src/core/engine/record_writer.dart';
import 'package:dual_store/src/interfaces/i_engine.dart';
import 'package:dual_store/src/interfaces/i_meta.dart';
import 'package:dual_store/src/interfaces/i_writer.dart';

///record[
///meader[magic(4),version(1),total(4)]
///record[id(3),flag(1),parentId(4),adapterId(1),queryType(1),dataType(1),dataSize(4),data(n bytes)]
///]
class CoreEngine implements IEngine {
  final RandomAccessFile _writeRaf;
  final RandomAccessFile _readRaf;
  CoreEngine(this._writeRaf, this._readRaf);

  static Future<CoreEngine> open(String path) async {
    final file = File(path);

    final writeRaf = await file.open(mode: .append);
    final readRaf = await file.open(mode: .read);
    return CoreEngine(writeRaf, readRaf);
  }

  @override
  Future<void> close() async {
    await _readRaf.close();
    await _writeRaf.close();
  }

  @override
  Future<List<IMeta>> getAllMetas() async {
    return await RecordMetaParser(_readRaf).parseAll();
  }

  @override
  Stream<List<int>> readData(IMeta meta) {
    return RecordStreamReader(_readRaf).readData(meta);
  }

  @override
  Future<void> write(
    IRecordWriter writer, {
    OnWriterProgerssCallback? onProgress,
  }) async {
    await RecordWriter(_writeRaf).write(writer, onProgress: onProgress);
  }
}
