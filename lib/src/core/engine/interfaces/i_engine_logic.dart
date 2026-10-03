import 'dart:async';
import 'dart:io';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/meta_info.dart';
import 'package:dual_store/src/core/engine/events/du_event_state.dart';
import 'package:dual_store/src/core/engine/writer/i_meta_writer.dart';
import 'package:dual_store/src/core/models/engine_context.dart';
import 'package:dual_store/src/result_t.dart';

// ignore: public_member_api_docs
abstract class IEngineLogic {
  /// state
  EngineContext get ctx;

  /// header
  Result<DuHeader, String> readHeader(RandomAccessFile readRaf);

  /// write header
  Result<bool, String> writeHeader(RandomAccessFile writeRaf, DuHeader header);

  ///meta
  Future<Result<MetaInfo, String>> getMetaInfo(String path);

  /// db change path
  Future<Result<bool, String>> changePath(String path);

  ///db reload
  Future<Result<bool, String>> reload();

  /// ### Open DB
  Future<Result<bool, String>> open(String path);

  /// flushes the contents of the file to disk.
  Future<Result<bool, String>> flush();

  /// Close DB
  Future<Result<bool, String>> close();

  ///write
  Future<Result<bool, String>> writeRecord(
    IMetaWriter metaWriter,
    IContentWriter contentWriter, {
    bool diskFlush = true,
    required int id,
  });

  ///all event controller
  final eventController = StreamController<DuEvent>.broadcast();

  /// all event state
  late final DuEventState events = DuEventState(
    all: eventController.stream,
    open: eventController.stream.whereType<Open>(),
    close: eventController.stream.whereType<Close>(),
    reload: eventController.stream.whereType<Reload>(),
    updateId: eventController.stream.whereType<UpdateId>(),
    addId: eventController.stream.whereType<AddId>(),
    deleteId: eventController.stream.whereType<DeleteId>(),
    changePath: eventController.stream.whereType<ChangePath>(),
    error: DuEventErrorState(
      duError: eventController.stream.whereType<DuError>(),
      writeRecordError: eventController.stream.whereType<WriteRecordError>(),
      removeMetaError: eventController.stream.whereType<RemoveMetaError>(),
      all: eventController.stream.where(
        (e) => e is DuError || e is WriteRecordError || e is RemoveMetaError,
      ),
    ),
    compact: DuCompactEvent(
      all: eventController.stream.whereType<CompactEvent>(),
      success: eventController.stream.whereType<CompactSuccess>(),
      error: eventController.stream.whereType<CompactError>(),
    ),
    box: DuBoxEvent(
      all: eventController.stream.whereType<BoxEvent>(),
      add: eventController.stream.whereType<BoxAdded>(),
      update: eventController.stream.whereType<BoxUpdated>(),
      delete: eventController.stream.whereType<BoxDeleted>(),
      readMetaError: eventController.stream.whereType<BoxReadMetaError>(),
      error: eventController.stream.whereType<BoxError>(),
    ),
  );
}
