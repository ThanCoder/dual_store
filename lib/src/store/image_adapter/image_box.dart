// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

class ImageBox extends IImageBox {
  final IDuMetaAdapter<ImageData> _adapter;
  final IDualStore _store;
  ImageBox({required this._adapter, required this._store});

  ///registerd adapter id
  @override
  int get adapterId => _adapter.adapterId;

  late final _allEvent = _store._eng.events.box.all
      .where((e) => e is ImageBoxEvent && e.adapterId == _adapter.adapterId)
      .cast<ImageBoxEvent>();
  @override
  late final events = ImageBoxEventState(
    all: _allEvent,
    add: _allEvent.whereType<ImageBoxAdded>(),
    update: _allEvent.whereType<ImageBoxUpdated>(),
    delete: _allEvent.whereType<ImageBoxDeleted>(),
    error: _allEvent.whereType<ImageBoxError>(),
  );

  @override
  Future<ImageData?> getById(int generatedId, {int? parentId}) async {
    await for (var item in streamAll(parentId: parentId)) {
      if (item.generatedId == generatedId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<ImageData?> getOne({int? parentId}) async {
    for (var val in await getAll(parentId: parentId)) {
      return val;
    }
    return null;
  }

  @override
  Future<List<ImageData>> findAll(
    bool Function(ImageData file) onTest, {
    int? parentId,
  }) async {
    final list = <ImageData>[];
    try {
      await for (var val in streamAll(parentId: parentId)) {
        if (onTest(val)) {
          list.add(val);
        }
      }
    } catch (e) {
      _store._eng.eventController.add(
        DuError('[DuBox:findAll]: ${e.toString()}'),
      );
      _store._eng.eventController.add(
        BoxError(id: -1, adapterId: _adapter.adapterId, message: e.toString()),
      );
    }
    return list;
  }

  @override
  Future<ImageData?> findOne(
    bool Function(ImageData file) onTest, {
    int? parentId,
  }) async {
    try {
      await for (var val in streamAll(parentId: parentId)) {
        if (onTest(val)) {
          return val;
        }
      }
    } catch (e) {
      _store._eng.eventController.add(
        DuError('[DuBox:findAll]: ${e.toString()}'),
      );
      _store._eng.eventController.add(
        BoxError(id: -1, adapterId: _adapter.adapterId, message: e.toString()),
      );
    }
    return null;
  }

  @override
  Stream<ImageData> streamAll({int? parentId}) async* {
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
        val._generatedId = meta.id;
        val._box = this;

        // add list
        yield val;
      } catch (e) {
        _store._eng.eventController.add(ImageBoxError(meta.id, e.toString()));
      }
    }
  }

  @override
  Future<List<ImageData>> getAll({int? parentId}) async {
    final list = <ImageData>[];
    try {
      await for (var val in streamAll(parentId: parentId)) {
        list.add(val);
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
  Future<Result<int, String>> add(
    IImageFile file, {
    bool diskFlush = true,
  }) async {
    try {
      final imageData = file.toImageData;
      final imageBytes = await file.toImageBytes;
      final generatedId = _store._eng.ctx.generatedId;
      final res = await _store._eng.writeRecord(
        _adapter.toMetaWriter(imageData),
        BytesRawContentWriter(bytes: imageBytes),
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
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
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

  @override
  Uint8List? getContentSync(IImageDuModel value) {
    final res = _store._eng.readContentSync<Uint8List>(value._meta);
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

  @override
  Future<Result<bool, String>> deleteImage(
    ImageData file, {
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

  @override
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

  @override
  Future<Result<bool, String>> updateById(
    int id, {
    required IImageFile file,
    bool diskFlush = true,
  }) async {
    try {
      final bytes = await file.toImageBytes;

      final remRes = await _store._eng.removeMetaById(id);
      if (remRes.isErr) {
        return Err(remRes.unwrapError());
      }
      final res = await _store._eng.writeRecord(
        _adapter.toMetaWriter(file.toImageData),
        BytesRawContentWriter(bytes: bytes),
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
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<List<(int, bool)>> deleteAll({
    bool diskFlush = true,
    int? parentId,
  }) async {
    final results = <(int, bool)>[];
    await for (var item in streamAll(parentId: parentId)) {
      final res = await item.delete();
      results.add((item.generatedId, res.isOk));
    }
    return results;
  }

  @override
  Future<Result<bool, String>> updateOne(
    bool Function(ImageData data) test, {
    required IImageFile file,
    bool diskFlush = true,
    int? parentId,
  }) async {
    await for (var item in streamAll(parentId: parentId)) {
      if (test(item)) {
        return Ok(true);
      }
    }
    return Ok(false);
  }

  @override
  Future<Result<bool, String>> deleteOne(
    bool Function(ImageData data) test, {
    bool diskFlush = true,
    int? parentId,
  }) async {
    await for (var item in streamAll(parentId: parentId)) {
      if (test(item)) {
        return await item.delete();
      }
    }
    return Ok(false);
  }
}
