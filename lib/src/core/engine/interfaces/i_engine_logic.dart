import 'dart:async';
import 'dart:io';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/meta_info.dart';
import 'package:dual_store/src/store/du_event_state.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/result_t.dart';

abstract class IEngineLogic {
  EngineContext get ctx;
  // header
  Result<DuHeader, String> readHeader(RandomAccessFile readRaf);
  Result<bool, String> writeHeader(RandomAccessFile writeRaf, DuHeader header);
  //meta
  Future<Result<MetaInfo, String>> getMetaInfo(String path);
  Result<MetaInfo, String> getMetaInfoSync(String path);

  Future<Result<bool, String>> reload();
  Result<bool, String> reloadSync();

  /// ### Open DB
  Future<Result<bool, String>> open(String path);

  /// ### Open DB Sync
  Result<bool, String> openSync(String path);

  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> flushSync();

  /// flushes the contents of the file to disk.
  Future<Result<bool, String>> flush();

  /// Close DB
  Result<bool, String> closeSync();

  /// Close DB
  Future<Result<bool, String>> close();

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

  final eventController = StreamController<DuEvent>.broadcast();
  late final DuEventState events = DuEventState(
    all: eventController.stream,
    open: eventController.stream.whereType<Open>(),
    close: eventController.stream.whereType<Close>(),
    reload: eventController.stream.whereType<Reload>(),
    updateId: eventController.stream.whereType<UpdateId>(),
    addId: eventController.stream.whereType<AddId>(),
    deleteId: eventController.stream.whereType<DeleteId>(),
  );
}
