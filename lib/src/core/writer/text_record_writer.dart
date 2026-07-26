import 'dart:convert';

import 'package:dual_store/src/interfaces/i_writer.dart';
import 'package:dual_store/src/interfaces/types.dart';

class TextRecordWriter extends BaseRecordWriter {
  final String text;
  const TextRecordWriter({
    required this.text,
    required super.id,
    super.parentId = -1,
    super.adapterId = -1,
    super.flag = .active,
    super.queryType = QueryType.none,
    super.dataType = DataType.text,
  });

  @override
  Stream<List<int>> writeChunks() {
    return Stream.fromIterable([utf8.encode(text)]);
  }

  @override
  int? get totalDataSize => null;
}
