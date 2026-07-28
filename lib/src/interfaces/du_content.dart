// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/types.dart';

sealed class DuContent {
  DuContentDataType get contentType;
  int get length;
}

class EmptyContent extends DuContent {
  @override
  DuContentDataType get contentType => DuContentDataType.none;

  @override
  int get length => 0;
}

class TextContent extends DuContent {
  final String text;
  TextContent(this.text);
  @override
  DuContentDataType get contentType => DuContentDataType.text;

  late final _bytes = Uint8List.fromList(utf8.encode(text));

  Uint8List get bytes => _bytes;

  @override
  int get length => _bytes.length;
}

class BytesContent extends DuContent {
  Uint8List bytes;
  BytesContent(this.bytes);

  @override
  int get length => bytes.length;

  @override
  DuContentDataType get contentType => DuContentDataType.bytes;
}

class StreamContent extends DuContent {
  final Stream<List<int>> stream;
  @override
  final int length;
  StreamContent(this.stream, this.length);

  @override
  DuContentDataType get contentType => DuContentDataType.stream;
}
