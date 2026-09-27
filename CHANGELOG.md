# 0.1.0

* Initial release.
* Added persistent local database storage.
* Added typed `DuBox<T>` support.
* Added custom model adapter system with `IDuMetaAdapter`.
* Added automatic record ID generation.
* Added database open, close, reload, and path management.
* Added conditional database opening with `openIfNotOpened()`.
* Added `flush()` support for syncing database contents to disk.
* Added database and box event streams.
* Added error event handling.
* Added database state tracking:

  * `lastId`
  * `deletedCount`
  * `deletedSize`
* Added database compaction support.
* Added `Result<T, String>` based database operation results.
* Added model serialization and deserialization through adapters.
* Added Flutter-friendly reactive database events.
* Added Todo example demonstrating CRUD operations and database compaction.
