import 'package:dual_store/src/core/engine/events/du_event.dart';

/// event
class DuEventState {
  /// event
  const DuEventState({
    required this.all,
    required this.open,
    required this.close,
    required this.reload,
    required this.updateId,
    required this.addId,
    required this.deleteId,
    required this.changePath,
    required this.error,
    required this.compact,
    required this.box,
  });

  /// all event
  final Stream<DuEvent> all;

  /// db open
  final Stream<Open> open;

  /// db close
  final Stream<Close> close;

  /// db reload
  final Stream<Reload> reload;

  /// box update
  final Stream<UpdateId> updateId;

  /// box add
  final Stream<AddId> addId;

  /// delete event
  final Stream<DeleteId> deleteId;

  /// change event
  final Stream<ChangePath> changePath;

  /// all error
  final DuEventErrorState error;

  /// compact event
  final DuCompactEvent compact;

  /// box event
  final DuBoxEvent box;
}

// ignore: public_member_api_docs
class DuEventErrorState {
  // ignore: public_member_api_docs
  const DuEventErrorState({
    required this.duError,
    required this.writeRecordError,
    required this.all,
    required this.removeMetaError,
  });

  /// du error
  final Stream<DuError> duError;

  ///low level write record error
  final Stream<WriteRecordError> writeRecordError;

  /// all error events
  final Stream<DuEvent> all;

  /// low level remove meta or delete box
  final Stream<RemoveMetaError> removeMetaError;
}

///compact event
class DuCompactEvent {
  ///compact all event
  final Stream<CompactEvent> all;

  ///compact success event
  final Stream<CompactSuccess> success;

  ///compact error event
  final Stream<CompactError> error;

  ///compact event
  const DuCompactEvent({
    required this.all,
    required this.success,
    required this.error,
  });
}

///box event
class DuBoxEvent {
  /// box all event
  final Stream<BoxEvent> all;

  /// add box
  final Stream<BoxAdded> add;

  /// box update
  final Stream<BoxUpdated> update;

  /// box delete
  final Stream<BoxDeleted> delete;

  /// box error
  final Stream<BoxError> error;

  /// box read meta error
  final Stream<BoxReadMetaError> readMetaError;

  ///box event
  const DuBoxEvent({
    required this.all,
    required this.add,
    required this.update,
    required this.delete,
    required this.readMetaError,
    required this.error,
  });
}

// ignore: public_member_api_docs
extension DuEventStateExt on Stream<DuEvent> {
  // ignore: public_member_api_docs
  Stream<T> whereType<T>() {
    return where((e) => e is T).cast<T>();
  }
}
