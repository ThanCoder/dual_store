enum DuFlag {
  deleted(0),
  active(1);

  final int value;
  const DuFlag(this.value);

  static DuFlag fromValue(int val) {
    return values.firstWhere((e) => e.value == val, orElse: () => deleted);
  }
}

enum RecordType {
  meta(0),
  content(1);

  final int value;
  const RecordType(this.value);

  static RecordType fromValue(int val) {
    return values.firstWhere((e) => e.value == val, orElse: () => meta);
  }
}

enum DuMetaType {
  unknown(-1),
  json(1);

  final int value;
  const DuMetaType(this.value);

  static DuMetaType fromValue(int val) {
    return values.firstWhere((e) => e.value == val, orElse: () => unknown);
  }
}

enum DuContentDataType {
  none(0),
  text(1),
  json(2),
  bytes(3),
  stream(4),
  file(5);

  final int value;
  const DuContentDataType(this.value);

  static DuContentDataType fromValue(int val) {
    return values.firstWhere((e) => e.value == val, orElse: () => none);
  }
}

enum DuContentFlag {
  none(0),
  raw(0),
  compressed(1);

  final int value;
  const DuContentFlag(this.value);

  static DuContentFlag fromValue(int val) {
    return values.firstWhere((e) => e.value == val, orElse: () => none);
  }
}
