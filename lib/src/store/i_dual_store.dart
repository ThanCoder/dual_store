part of 'dual_store_base.dart';

sealed class IDualStore {
  //*************Adapter******************** */
  final _adapters = <Type, IDuMetaAdapter>{};
  final _boxs = <Type, DuBox>{};

  DuBox<T> getBox<T extends IDuModel>() {
    final box = _boxs[T];
    if (box == null) {
      throw Exception('Need To Register $T Adapter!');
    }
    return box as DuBox<T>;
  }

  //*************Engine******************** */
  final _eng = DualEngine();

  Result<bool, String> close() {
    return _eng.close();
  }

  Future<Result<bool, String>> flush() async {
    return await _eng.flush();
  }

  Result<bool, String> flushSync() {
    return _eng.flushSync();
  }

  //*************Events******************** */
  Stream<DuEvent> get _events => _eng.eventController.stream;

  late final DuEventState events = .new(
    all: _events.whereType<DuEvent>(),
    open: _events.whereType<Open>(),
    close: _events.whereType<Close>(),
    reload: _events.whereType<Reload>(),
    updateId: _events.whereType<UpdateId>(),
    addId: _events.whereType<AddId>(),
    deleteId: _events.whereType<DeleteId>(),
  );

  //*************State******************** */
  late final DuCtxState state = DuCtxState(_eng.ctx);
}
