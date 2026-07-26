enum RecordFlag {
  deleted(0),
  active(1);

  final int value;
  const RecordFlag(this.value);
}

enum DataType {
  query(1),
  text(2),
  file(3);

  final int value;
  const DataType(this.value);

  static DataType fromValue(int val) {
    return DataType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => query,
    );
  }
}

enum QueryType {
  none(0),
  json(1),
  binaryQuery(2);

  final int value;
  const QueryType(this.value);

  static QueryType fromValue(int val) {
    return QueryType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => none,
    );
  }
}
