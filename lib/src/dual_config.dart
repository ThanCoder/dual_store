class DualConfig {
  /// If true, all [smallData] will be cached in RAM during the indexing phase.
  ///
  /// Set to [false] if you have millions of records to save memory.
  final bool useRamSmallData;

  /// If true, the engine will automatically run [compact()] when the
  ///
  /// thresholds are met.
  final bool autoCompact;

  /// Trigger [compact()] when the number of deleted records exceeds this value.
  final int willCompactDeletedCount;

  /// Trigger [compact()] when the total size of deleted data (in bytes)
  ///
  /// exceeds this value.
  final int willCompactDeletedSize;

  ///
  /// Compact Write Memory Buffer Size
  ///
  final int compactBufferSize;

  ///
  /// When Compact Finish Will Rename Old Database Backup File.
  ///
  final bool saveLastCompactOldDBBackupFile;

  ///
  /// Big Data Compresser in `BigDataType.stringText`
  ///
  /// !Not Working -> `BigDataType.file`
  ///
  final bool useBigDataGzipEncoder;

  const DualConfig({
    this.useBigDataGzipEncoder = true,
    this.useRamSmallData = true,
    this.autoCompact = true,
    this.willCompactDeletedCount = 1000,
    this.willCompactDeletedSize = 50 * 1024 * 1024, // 50 MB
    this.compactBufferSize = 64 * 1024, //64kb
    this.saveLastCompactOldDBBackupFile = false,
  });
}
