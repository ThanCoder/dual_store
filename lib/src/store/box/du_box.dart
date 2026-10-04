// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

// class BoxEvent {}

class DuBox<T extends IDuModel> implements IDuBox<T> {
  final IDuMetaAdapter<T> _adapter;
  final IDualStore _store;
  DuBox({required this._adapter, required this._store});

  //*********Events******************/
  late final _allEvent = _store._eng.events.box.all.where(
    (e) => e.adapterId == _adapter.adapterId,
  );
  late final events = DuBoxEvent(
    all: _allEvent,
    add: _allEvent.whereType<BoxAdded>(),
    update: _allEvent.whereType<BoxUpdated>(),
    delete: _allEvent.whereType<BoxDeleted>(),
    readMetaError: _allEvent.whereType<BoxReadMetaError>(),
    error: _allEvent.whereType<BoxError>(),
  );

  //*********stream******************/
  @override
  Stream<T> streamAll({int? parentId}) async* {
    try {
      final allMetaIds = _store._eng.ctx.adapterMeta[_adapter.adapterId];
      if (allMetaIds == null) return;

      for (var metaId in allMetaIds.toList()) {
        final meta = _store._eng.ctx.allMeta[metaId];
        if (meta == null) continue;

        if (parentId != null && meta.parentId != parentId) continue;
        try {
          final reader = _adapter.toMetaReader(meta.metaData);
          final val = _adapter.fromMap(reader.decode());
          // add private model
          val._meta = meta;
          val._box = this;
          // add list
          yield val;
        } catch (e) {
          _store._eng.eventController.add(
            BoxReadMetaError(
              id: meta.id,
              adapterId: meta.adapterId,
              message: e.toString(),
            ),
          );
        }
      }
    } catch (e) {
      _store._eng.eventController.add(
        DuError('[DuBox:getAll]: ${e.toString()}'),
      );
      _store._eng.eventController.add(
        BoxError(id: -1, adapterId: _adapter.adapterId, message: e.toString()),
      );
    }
  }

  @override
  Stream<T?> streamFindOne(bool Function(T val) test, {int? parentId}) async* {
    await for (var meta in streamAll(parentId: parentId)) {
      if (test(meta)) {
        yield meta;
        return;
      }
    }
    yield null;
  }

  @override
  Stream<T> streamFind(bool Function(T val) test, {int? parentId}) async* {
    await for (var meta in streamAll(parentId: parentId)) {
      if (test(meta)) {
        yield meta;
      }
    }
  }

  //*********normal******************/
  @override
  Future<Result<T, String>> getById(int id) async {
    try {
      final meta = _store._eng.ctx.allMeta[id];
      if (meta == null) {
        return Err('id not found!');
      }
      if (meta.adapterId != _adapter.adapterId) {
        return Err('id not found!');
      }
      final reader = _adapter.toMetaReader(meta.metaData);
      final val = _adapter.fromMap(reader.decode());
      val._meta = meta;
      val._box = this;

      return Ok(val);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<T?> findOne(bool Function(T val) onTest, {int? parentId}) async {
    final list = await getAll(parentId: parentId);

    for (var val in list) {
      if (onTest(val)) return val;
    }
    return null;
  }

  @override
  Future<List<T>> find(bool Function(T val) onTest, {int? parentId}) async {
    List<T> res = [];
    final list = await getAll(parentId: parentId);

    for (var val in list) {
      if (onTest(val)) {
        res.add(val);
      }
    }
    return res;
  }

  @override
  Future<List<T>> getAll({int? parentId}) async {
    final list = <T>[];
    try {
      final allMetaIds = _store._eng.ctx.adapterMeta[_adapter.adapterId];
      if (allMetaIds == null) return [];

      for (var metaId in allMetaIds.toList()) {
        final meta = _store._eng.ctx.allMeta[metaId];
        if (meta == null) continue;

        if (parentId != null && meta.parentId != parentId) continue;
        try {
          final reader = _adapter.toMetaReader(meta.metaData);
          final val = _adapter.fromMap(reader.decode());
          // add private model
          val._meta = meta;
          val._box = this;
          // add list
          list.add(val);
        } catch (e) {
          _store._eng.eventController.add(
            BoxReadMetaError(
              id: meta.id,
              adapterId: meta.adapterId,
              message: e.toString(),
            ),
          );
        }
      }
    } catch (e) {
      _store._eng.eventController.add(
        DuError('[DuBox:getAll]: ${e.toString()}'),
      );
      _store._eng.eventController.add(
        BoxError(id: -1, adapterId: _adapter.adapterId, message: e.toString()),
      );
    }
    return list;
  }

  @override
  Future<Result<R, String>> getContent<R>(T value) async {
    final res = await _store._eng.readContent<R>(value._meta);
    if (res.isErr) {
      _store._eng.eventController.add(
        BoxError(
          id: value.generatedId,
          adapterId: _adapter.adapterId,
          message: res.unwrapError(),
        ),
      );
    }
    return res;
  }

  @override
  Future<Result<int, String>> add(
    T value, {
    IContentWriter contentWriter = const NoneContentWriter(),
    bool diskFlush = true,
  }) async {
    final generatedId = _store._eng.ctx.generatedId;
    final res = await _store._eng.writeRecord(
      _adapter.toMetaWriter(value),
      contentWriter,
      id: generatedId,
      diskFlush: diskFlush,
    );
    if (res.isErr) {
      _store._eng.eventController.add(
        BoxError(
          id: generatedId,
          adapterId: _adapter.adapterId,
          message: res.unwrapError(),
        ),
      );
      return Err(res.unwrapError());
    }
    _store._eng.eventController.add(
      BoxAdded(id: generatedId, adapterId: _adapter.adapterId),
    );

    return Ok(generatedId);
  }

  @override
  Future<Result<bool, String>> update(
    int id, {
    required T value,
    IContentWriter contentWriter = const NoneContentWriter(),
  }) async {
    final remRes = await _store._eng.removeMetaById(id);
    if (remRes.isErr) {
      return Err(remRes.unwrapError());
    }
    final res = await _store._eng.writeRecord(
      _adapter.toMetaWriter(value),
      contentWriter,
      id: id,
    );
    if (res.isOk) {
      _store._eng.eventController.add(
        BoxUpdated(id: id, adapterId: _adapter.adapterId),
      );
    }
    if (res.isErr) {
      _store._eng.eventController.add(
        BoxError(
          id: value.generatedId,
          adapterId: _adapter.adapterId,
          message: res.unwrapError(),
        ),
      );
    }
    return res;
  }

  @override
  Future<Result<bool, String>> deleteById(
    int id, {
    bool diskFlush = true,
  }) async {
    final res = await _store._eng.removeMetaById(id, diskFlush: diskFlush);
    if (res.isOk) {
      _store._eng.eventController.add(
        BoxDeleted(id: id, adapterId: _adapter.adapterId),
      );
    }
    if (res.isErr) {
      _store._eng.eventController.add(
        BoxError(
          id: id,
          adapterId: _adapter.adapterId,
          message: res.unwrapError(),
        ),
      );
    }
    return res;
  }
}
