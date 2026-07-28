/// [magic(4),version(1),dbID(1)]
class DuHeader {
  final String magic;
  final int version;
  final int dbID;
  const DuHeader({required this.magic, this.version = 1, this.dbID = 0});

  @override
  String toString() =>
      'DuHeader(magic: $magic, version: $version, dbID: $dbID)';
}