/// [magic(4),version(1),dbID(1)]
class DuHeader {
  /// magic number
  final String magic;

  /// version number
  final int version;

  /// unique db id
  final int dbID;

  /// header
  const DuHeader({required this.magic, this.version = 1, this.dbID = 0});

  @override
  String toString() =>
      'DuHeader(magic: $magic, version: $version, dbID: $dbID)';
}
