import 'package:dual_store/src/interfaces/types.dart';

abstract class IMeta {
  int get id;
  int get parentId;
  int get adapterId;
  QueryType get queryType;
  DataType get dataType;
  RecordFlag get flag;

  int get recordOffset;
  int get dataSize;
}

/// Memory ပေါ်မှာ သိမ်းထားမည့် metadata block အစစ်
class RecordMeta implements IMeta {
  @override
  final int id;
  @override
  final RecordFlag flag;
  @override
  final int parentId;
  @override
  final int adapterId;
  @override
  final QueryType queryType;
  @override
  final DataType dataType;

  @override
  final int recordOffset;
  @override
  final int dataSize;

  RecordMeta({
    required this.id,
    required this.flag,
    required this.parentId,
    required this.adapterId,
    required this.queryType,
    required this.dataType,
    required this.recordOffset,
    required this.dataSize,
  });

  @override
  String toString() {
    return 'RecordMeta(id: $id, flag: $flag, parentId: $parentId, adapterId: $adapterId, queryType: $queryType, dataType: $dataType, recordOffset: $recordOffset, dataSize: $dataSize)';
  }
}
