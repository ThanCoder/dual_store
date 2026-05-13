import 'package:dual_store/src/databases/record_meta.dart';

abstract class DualModel {
  /// The unique database record ID.
  int? autoId;

  /// Holds the physical metadata of the record from the disk.
  /// This is useful for updates, deletes, and tracking offsets.
  RecordMeta? meta;
}
