import 'package:dual_store/src/core/engine/events/du_event.dart';

class DuEventState {
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
  });
  final Stream<DuEvent> all;
  final Stream<Open> open;
  final Stream<Close> close;
  final Stream<Reload> reload;
  final Stream<UpdateId> updateId;
  final Stream<AddId> addId;
  final Stream<DeleteId> deleteId;
  final Stream<ChangePath> changePath;
  final DuEventErrorState error;
}

class DuEventErrorState {
  const DuEventErrorState({
    required this.duError,
    required this.writeRecordError,
    required this.all,
    required this.removeMetaError,
  });
  final Stream<DuError> duError;
  final Stream<WriteRecordError> writeRecordError;
  final Stream<DuEvent> all;
  final Stream<RemoveMetaError> removeMetaError;
}

extension DuEventStateExt on Stream<DuEvent> {
  Stream<T> whereType<T>() {
    return where((e) => e is T).cast<T>();
  }
}
