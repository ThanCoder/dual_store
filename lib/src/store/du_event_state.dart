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
  });
  final Stream<DuEvent> all;
  final Stream<Open> open;
  final Stream<Close> close;
  final Stream<Reload> reload;
  final Stream<UpdateId> updateId;
  final Stream<AddId> addId;
  final Stream<DeleteId> deleteId;
}

extension DuEventStateExt on Stream<DuEvent> {
  Stream<T> whereType<T>() {
    return where((e) => e is T).cast<T>();
  }
}
