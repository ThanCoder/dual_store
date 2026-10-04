// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/types.dart';

///header
///[
/// contentFlags(1)
/// contentType(1),contentSize(8),
/// contentData(n bytes)
///]
abstract class IContentWriter {
  const IContentWriter();

  DuContentFlag get contentFlag;
  DuContentDataType get dataType;
  int get size;

  /// written bytes
  /// return data length
  Future<int> writeTo(RandomAccessFile raf);

  /// written bytes
  /// return data length
  int writeToSync(RandomAccessFile raf);
}

class NoneContentWriter implements IContentWriter {
  const NoneContentWriter();
  @override
  DuContentFlag get contentFlag => DuContentFlag.none;

  @override
  DuContentDataType get dataType => DuContentDataType.none;

  @override
  int get size => 0;

  @override
  Future<int> writeTo(RandomAccessFile raf) async => 0;
  @override
  int writeToSync(RandomAccessFile raf) => 0;
}

class TextRawContentWriter implements IContentWriter {
  final Uint8List _data;
  TextRawContentWriter(String text) : _data = utf8.encode(text);

  @override
  DuContentFlag get contentFlag => DuContentFlag.raw;

  @override
  DuContentDataType get dataType => DuContentDataType.text;

  @override
  int get size => _data.length;

  @override
  Future<int> writeTo(RandomAccessFile raf) async {
    await raf.writeFrom(_data);
    return _data.length;
  }

  @override
  int writeToSync(RandomAccessFile raf) {
    raf.writeFromSync(_data);
    return _data.length;
  }
}

class JsonRawContentWriter implements IContentWriter {
  final Uint8List _data;
  JsonRawContentWriter(Map<String, dynamic> map)
    : _data = utf8.encode(jsonEncode(map));

  @override
  DuContentFlag get contentFlag => DuContentFlag.raw;

  @override
  DuContentDataType get dataType => DuContentDataType.json;

  @override
  int get size => _data.length;

  @override
  Future<int> writeTo(RandomAccessFile raf) async {
    await raf.writeFrom(_data);
    return _data.length;
  }

  @override
  int writeToSync(RandomAccessFile raf) {
    raf.writeFromSync(_data);
    return _data.length;
  }
}

//*******************Compress Writer************************** */
class TextCompressContentWriter implements IContentWriter {
  final Uint8List _data;
  TextCompressContentWriter(String text)
    : _data = Uint8List.fromList(gzip.encode(utf8.encode(text)));

  @override
  DuContentFlag get contentFlag => DuContentFlag.compressed;

  @override
  DuContentDataType get dataType => DuContentDataType.text;

  @override
  int get size => _data.length;

  @override
  Future<int> writeTo(RandomAccessFile raf) async {
    await raf.writeFrom(_data);
    return _data.length;
  }

  @override
  int writeToSync(RandomAccessFile raf) {
    raf.writeFromSync(_data);
    return _data.length;
  }
}

//*******************File Writer************************** */
class BytesRawContentWriter implements IContentWriter {
  final Uint8List _bytes;

  const BytesRawContentWriter({required this._bytes});
  @override
  DuContentFlag get contentFlag => .raw;

  @override
  DuContentDataType get dataType => .bytes;

  @override
  int get size => _bytes.length;

  @override
  Future<int> writeTo(RandomAccessFile raf) async {
    await raf.writeFrom(_bytes);
    return size;
  }

  @override
  int writeToSync(RandomAccessFile raf) {
    raf.writeFromSync(_bytes);
    return size;
  }
}

class BytesCompressContentWriter implements IContentWriter {
  final Uint8List _data;
  BytesCompressContentWriter(Uint8List bytes)
    : _data = Uint8List.fromList(gzip.encode(bytes));

  @override
  DuContentFlag get contentFlag => DuContentFlag.compressed;

  @override
  DuContentDataType get dataType => DuContentDataType.bytes;

  @override
  int get size => _data.length;

  @override
  Future<int> writeTo(RandomAccessFile raf) async {
    await raf.writeFrom(_data);
    return _data.length;
  }

  @override
  int writeToSync(RandomAccessFile raf) {
    raf.writeFromSync(_data);
    return _data.length;
  }
}
