import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';

abstract class IEngineLogic {
  EngineContext get ctx;

  /// ### Open DB
  Future<void> open(String path);

  /// ### Open DB Sync
  void openSync(String path);

  /// Synchronously flushes the contents of the file to disk.
  void flush();

  /// ### Close DB
  void close();

  Future<void> writeRecord(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
  });

  void writeRecordSync(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
  });
}
