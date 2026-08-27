import 'dart:convert';
import 'dart:io';

import 'package:dual_store/src/core/engine/interfaces/types.dart';
import 'package:dual_store/src/core/models/meta.dart';

abstract class IContentReader<R> {
  Meta get meta;
  DuContentFlag get contentFlag;
  DuContentDataType get contentDataType;
  Future<R> read(RandomAccessFile readRaf);
  R readSync(RandomAccessFile readRaf);
}

class TextRawContentReader implements IContentReader<String> {
  @override
  final Meta meta;
  const TextRawContentReader(this.meta);

  @override
  DuContentDataType get contentDataType => .text;

  @override
  DuContentFlag get contentFlag => .raw;

  @override
  String readSync(RandomAccessFile readRaf) {
    final data = readRaf.readSync(meta.contentSize);
    return utf8.decode(data);
  }

  @override
  Future<String> read(RandomAccessFile readRaf) async {
    final data = await readRaf.read(meta.contentSize);
    return utf8.decode(data);
  }
}

class JsonRawContentReader implements IContentReader<Map<String, dynamic>> {
  @override
  final Meta meta;
  const JsonRawContentReader(this.meta);

  @override
  DuContentDataType get contentDataType => .json;

  @override
  DuContentFlag get contentFlag => .raw;

  @override
  Map<String, dynamic> readSync(RandomAccessFile readRaf) {
    final data = readRaf.readSync(meta.contentSize);
    final str = utf8.decode(data);
    return jsonDecode(str);
  }

  @override
  Future<Map<String, dynamic>> read(RandomAccessFile readRaf) async {
    final data = await readRaf.read(meta.contentSize);
    final str = utf8.decode(data);
    return jsonDecode(str);
  }
}

//***********Compress Reader*********************** */
class TextCompressContentReader implements IContentReader<String> {
  @override
  final Meta meta;
  const TextCompressContentReader(this.meta);
  @override
  DuContentDataType get contentDataType => .text;

  @override
  DuContentFlag get contentFlag => .compressed;

  @override
  Future<String> read(RandomAccessFile readRaf) async {
    final data = await readRaf.read(meta.contentSize);
    return utf8.decode(gzip.decode(data));
  }

  @override
  String readSync(RandomAccessFile readRaf) {
    final data = readRaf.readSync(meta.contentSize);
    return utf8.decode(gzip.decode(data));
  }
}
