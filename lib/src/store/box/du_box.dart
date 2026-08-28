part of '../dual_store_base.dart';

class DuBox<T extends IDuModel> implements IDuBox<T> {
  final IDuMetaAdapter<T> _adapter;
  final DualStore _store;
  const DuBox({required this._adapter, required this._store});

  @override
  Future<List<T>> getAll() async {
    final list = <T>[];
    final allMeta = _store._eng.ctx.allMeta;
    for (var meta in allMeta.values) {
      if (meta.adapterId != _adapter.adapterId) continue;
      final reader = _adapter.toMetaReader(meta.metaData);
      final val = _adapter.fromMap(reader.decode());
      val._meta = meta;
      list.add(val);
    }
    return list;
  }

  @override
  Future<Result<bool, String>> add(
    T value, {
    IContentWriter contentWriter = const NoneContentWriter(),
  }) async {
    return await _store._eng.writeRecord(
      _adapter.toMetaWriter(value),
      contentWriter,
      id: _store._eng.ctx.generatedId,
    );
  }

  @override
  Future<Result<R, String>> getContent<R>(T value) async {
    return await _store._eng.readContent<R>(value._meta);
  }

  @override
  Future<Result<bool, String>> deleteById(int id) async {
    return await _store._eng.removeMetaById(id);
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
    return await _store._eng.writeRecord(
      _adapter.toMetaWriter(value),
      contentWriter,
      id: id,
    );
  }
}
