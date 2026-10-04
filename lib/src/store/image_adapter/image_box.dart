// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

class ImageBox {
  final IDuMetaAdapter<ImageFile> _adapter;
  final IDualStore _store;
  ImageBox({required this._adapter, required this._store});

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

  ///get all image
  Future<List<ImageFile>> getAll({int? parentId}) async {
    final list = <ImageFile>[];
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

  /// add image
  Future<Result<int, String>> add(
    ImageFile file, {
    bool diskFlush = true,
  }) async {
    final generatedId = _store._eng.ctx.generatedId;
    final res = await _store._eng.writeRecord(
      _adapter.toMetaWriter(file),
      BytesRawContentWriter(bytes: file._data!),
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

  /// IMAGE  bytes data
  Future<Result<Uint8List, String>> getContent(IImageDuModel value) async {
    final res = await _store._eng.readContent<Uint8List>(value._meta);
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

  /// delete image
  Future<Result<bool, String>> deleteImage(
    ImageFile file, {
    bool diskFlush = true,
  }) async {
    final res = await _store._eng.removeMetaById(
      file.generatedId,
      diskFlush: diskFlush,
    );
    if (res.isOk) {
      _store._eng.eventController.add(
        BoxDeleted(id: file.generatedId, adapterId: _adapter.adapterId),
      );
    }
    if (res.isErr) {
      _store._eng.eventController.add(
        BoxError(
          id: file.generatedId,
          adapterId: _adapter.adapterId,
          message: res.unwrapError(),
        ),
      );
    }
    return res;
  }

  /// delete by id
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
