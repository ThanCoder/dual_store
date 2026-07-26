import 'dart:convert';

import 'package:dual_store/src/interfaces/i_writer.dart';
import 'package:dual_store/src/interfaces/types.dart';

class JsonRecordWriter extends BaseRecordWriter {
  final Map<String, dynamic> map;
  JsonRecordWriter({
    required this.map,
    required super.id,
    super.parentId = -1,
    super.adapterId = -1,
    super.flag = RecordFlag.active,
    super.queryType = QueryType.json,
    super.dataType = DataType.query,
  });

  @override
  Stream<List<int>> writeChunks() {
    return Stream.fromIterable([utf8.encode(jsonEncode(map))]);
  }

  @override
  int? get totalDataSize => null;
}
