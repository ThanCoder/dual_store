enum RecordFlag {
  deleted(0),
  active(1);

  final int value;
  const RecordFlag(this.value);

  static RecordFlag fromValue(int val) {
    return values.firstWhere((e) => e.value == val, orElse: () => deleted);
  }
}

enum MetaType {
  unknown(-1),
  text(1),
  json(2),
  image(3);

  final int value;
  const MetaType(this.value);

  static MetaType fromValue(int val) {
    return MetaType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => unknown,
    );
  }
}

enum DataType {
  unknown(-1),
  text(1),
  image(2);

  final int value;
  const DataType(this.value);

  static DataType fromValue(int val) {
    return DataType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => unknown,
    );
  }
}
