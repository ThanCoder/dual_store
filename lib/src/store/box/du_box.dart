part of '../dual_store_base.dart';

class DuBox<T extends IDuModel> implements IDuBox<T> {
  final IDuMetaAdapter<T> _adapter;
  final DualStore _store;
  const DuBox({required this._adapter, required this._store});

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
      return Ok(val);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<T, String>> getOne(bool Function(T val) onTest) async {
    try {
      final listRes = await getAll();
      if (listRes.isErr) {
        return Err(listRes.unwrapError());
      }
      for (var val in listRes.unwrap()) {
        if (onTest(val)) return Ok(val);
      }
      return Err('Not Found!');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<T>, String>> getAll() async {
    try {
      final list = <T>[];
      final allMeta = _store._eng.ctx.allMeta;
      for (var meta in allMeta.values) {
        if (meta.adapterId != _adapter.adapterId) continue;
        final reader = _adapter.toMetaReader(meta.metaData);
        final val = _adapter.fromMap(reader.decode());
        val._meta = meta;
        list.add(val);
      }
      return Ok(list);
    } catch (e) {
      return Err(e.toString());
    }
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
  Future<Result<bool, String>> add(
    T value, {
    IContentWriter contentWriter = const NoneContentWriter(),
    bool diskFlush = true,
  }) async {
    final newId = _store._eng.ctx.generatedId;
    return await _store._eng.writeRecord(
      _adapter.toMetaWriter(value),
      contentWriter,
      id: newId,
      diskFlush: diskFlush,
    );
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
