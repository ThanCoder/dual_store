part of '../du_store.dart';

class DuBox<T extends IDuModel> {
  final IDuAdapter<T> _adapter;
  final DualEngine _engine;
  final IDuStore _store;
  const DuBox({
    required this._adapter,
    required this._engine,
    required this._store,
  });

  /// Return -> Generated Id
  Future<int> add(T value) async {
    final metaData = _adapter.encodeMeta(_adapter.toMeta(value));
    final content = _adapter.toContent(value) ?? Uint8List(0);

    final meta = _engine.writeRecord(
      DuRecord(
        id: _store._generated,
        adapterTypeId: _adapter.adapterTypeId,
        parentId: _adapter.getParentId(value),
        flag: .active,
        metaType: _adapter.metaType,
        dataType: _adapter.contentDataType,
        metaSize: metaData.length,
        metaData: metaData,
        dataSize: content.length,
        data: content,
      ),
    );
    _store._metaInfo.add(meta);
    _store._metaInfo.lastId = meta.id;
    _engine.flush();

    return meta.id;
  }

  /// Get All List
  Future<List<T>> getAll() async {
    List<T> list = [];

    for (var meta in _store._metaInfo.allMeta.values) {
      if (meta.adapterTypeId != _adapter.adapterTypeId) continue;

      final decodedMeta = _adapter.decodeMeta(meta.metaData);
      final val = _adapter.fromStorage(decodedMeta)
        ..generatedId = meta.id;

      list.add(val);
    }
    return list;
  }
}
