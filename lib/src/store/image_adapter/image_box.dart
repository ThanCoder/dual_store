// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

class ImageBox {
  final IDuMetaAdapter<ImageFile> _adapter;
  final IDualStore _store;
  ImageBox({required this._adapter, required this._store});

  ///registerd adapter id
  int get adapterId => _adapter.adapterId;

  late final _allEvent = _store._eng.events.box.all
      .where((e) => e is ImageBoxEvent && e.adapterId == _adapter.adapterId)
      .cast<ImageBoxEvent>();
  late final events = ImageBoxEventState(
    all: _allEvent,
    add: _allEvent.whereType<ImageBoxAdded>(),
    update: _allEvent.whereType<ImageBoxUpdated>(),
    delete: _allEvent.whereType<ImageBoxDeleted>(),
    error: _allEvent.whereType<ImageBoxError>(),
  );

  ///first one
  Future<ImageFile?> getOne({int? parentId}) async {
    for (var val in await getAll(parentId: parentId)) {
      return val;
    }
    return null;
  }

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
          _store._eng.eventController.add(ImageBoxError(meta.id, e.toString()));
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
        ImageBoxError(generatedId, res.unwrapError()),
      );
      return Err(res.unwrapError());
    }
    _store._eng.eventController.add(ImageBoxAdded(generatedId));

    return Ok(generatedId);
  }

  /// IMAGE  bytes data
  Future<Uint8List?> getContent(IImageDuModel value) async {
    final res = await _store._eng.readContent<Uint8List>(value._meta);
    if (res.isErr) {
      _store._eng.eventController.add(
        ImageBoxError(value.generatedId, res.unwrapError()),
      );
    }
    if (res.isOk) {
      return res.unwrap();
    }
    return null;
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
      _store._eng.eventController.add(ImageBoxDeleted(file.generatedId));
    }
    if (res.isErr) {
      _store._eng.eventController.add(
        ImageBoxError(file.generatedId, res.unwrapError()),
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
      _store._eng.eventController.add(ImageBoxDeleted(id));
    }
    if (res.isErr) {
      _store._eng.eventController.add(ImageBoxError(id, res.unwrapError()));
    }
    return res;
  }

  /// update by id
  Future<Result<bool, String>> updateById(
    int id, {
    required ImageFile file,
    bool diskFlush = true,
  }) async {
    final remRes = await _store._eng.removeMetaById(id);
    if (remRes.isErr) {
      return Err(remRes.unwrapError());
    }
    final res = await _store._eng.writeRecord(
      _adapter.toMetaWriter(file),
      BytesRawContentWriter(bytes: file._data!),
      diskFlush: diskFlush,
      id: id,
    );
    if (res.isOk) {
      _store._eng.eventController.add(ImageBoxUpdated(id));
    }
    if (res.isErr) {
      _store._eng.eventController.add(ImageBoxError(id, res.unwrapError()));
    }
    return res;
  }
}
