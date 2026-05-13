enum RecordFlag { deleted, active }

/// Don't use JSON for GB size data
enum BigDataType {
  ///
  /// No Data
  ///
  none,

  /// For small to medium text (up to few MBs).
  /// Avoid using for GB size data to prevent OOM (Out of Memory) errors.
  stringText,

  /// For structured data.
  /// The entire JSON will be loaded into RAM during decoding.
  /// Keep it small (under 10MB recommended).
  json,

  /// For Large Data (Videos, Databases, 1GB+ files).
  /// Handled via Stream, so it's memory-safe for any size.
  file,
}
