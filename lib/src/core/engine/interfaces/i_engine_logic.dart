import 'dart:io';

import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/result_t.dart';

abstract class IEngineLogic {
  EngineContext get ctx;
  RandomAccessFile get readRaf;
  RandomAccessFile get writeRaf;
  Future<Result<bool, String>> reload();
  Result<bool, String> reloadSync();

  /// ### Open DB
  Future<Result<bool, String>> open(String path);

  /// ### Open DB Sync
  Result<bool, String> openSync(String path);

  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> flush();

  /// ### Close DB
  Result<bool, String> close();

  Future<Result<bool, String>> writeRecord(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
    required int id,
  });

  Result<bool, String> writeRecordSync(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
    required int id,
  });
}
