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
  DuContentFlag get contentFlag;
  DuContentDataType get dataType;
  int get size;
  // written bytes
  Future<int> writeTo(RandomAccessFile raf);
  int writeToSync(RandomAccessFile raf);
}

class NoneContentWriter implements IContentWriter {
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
