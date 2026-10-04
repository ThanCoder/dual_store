// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

//***********Bytes reader*********************** */
class BytesRawContentReader implements IContentReader<Uint8List> {
  @override
  final Meta meta;
  const BytesRawContentReader(this.meta);

  @override
  DuContentDataType get contentDataType => .bytes;

  @override
  DuContentFlag get contentFlag => .raw;

  @override
  Future<Uint8List> read(RandomAccessFile readRaf) async {
    return await readRaf.read(meta.contentSize);
  }

  @override
  Uint8List readSync(RandomAccessFile readRaf) {
    return readRaf.readSync(meta.contentSize);
  }
}

class BytesCompressContentReader implements IContentReader<Uint8List> {
  @override
  final Meta meta;

  const BytesCompressContentReader(this.meta);

  @override
  DuContentDataType get contentDataType => .bytes;

  @override
  DuContentFlag get contentFlag => .compressed;

  @override
  Future<Uint8List> read(RandomAccessFile readRaf) async {
    final data = await readRaf.read(meta.contentSize);
    return Uint8List.fromList(gzip.decode(data));
  }

  @override
  Uint8List readSync(RandomAccessFile readRaf) {
    final data = readRaf.readSync(meta.contentSize);
    return Uint8List.fromList(gzip.decode(data));
  }
}
