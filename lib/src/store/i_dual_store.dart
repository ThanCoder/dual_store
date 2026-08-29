part of 'dual_store_base.dart';

sealed class IDualStore {
  //*************Events******************** */

  final _con = StreamController<DuEvent>.broadcast();
  late final DuEventState events = DuEventState(
    all: _con.stream,
    open: _con.stream.whereType<Open>(),
    close: _con.stream.whereType<Close>(),
    reload: _con.stream.whereType<Reload>(),
    updateId: _con.stream.whereType<UpdateId>(),
    addId: _con.stream.whereType<AddId>(),
    deleteId: _con.stream.whereType<DeleteId>(),
  );

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

  int get deletedCount => _eng.ctx.deletedCount;
  int get deletedSize => _eng.ctx.deletedSize;
  int get lastId => _eng.ctx.lastId;
  DuHeader get header => _eng.ctx.header;
}
