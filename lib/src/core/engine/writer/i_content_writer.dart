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

class NoneContentWriter extends IContentWriter {
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

class TextContentWriter extends IContentWriter {
  final Uint8List _data;
  TextContentWriter(String text) : _data = utf8.encode(text);

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
