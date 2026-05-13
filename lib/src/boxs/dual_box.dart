import 'dart:convert';
import 'dart:io';

import 'package:dual_store/src/databases/dual_record.dart';
import 'package:dual_store/src/databases/indexed_db.dart';
import 'package:dual_store/src/encoders/small_data_decoder.dart';
import 'package:dual_store/src/encoders/small_data_encoder.dart';
import 'package:dual_store/src/interfaces/dual_adapter.dart';
import 'package:dual_store/src/interfaces/dual_box_crud.dart';
import 'package:dual_store/src/interfaces/dual_model.dart';
import 'package:dual_store/src/types.dart';

class DualBox<T extends DualModel> extends DualBoxCrud<T> {
  final DualAdapter<T> _adapter;
  final IndexedDb _indexedDb;

  DualBox(DualAdapter<T> adapter, IndexedDb indexedDb)
    : _adapter = adapter,
      _indexedDb = indexedDb;

  @override
  Future<void> add(
    T value, {
    Stream<List<int>>? bigDataStream,
    int? bigDataSize,
    void Function(double progerss)? onProgress,
  }) async {
    final id = _indexedDb.generatedIndex;
    final smallEncoder = SmallDataEncoder();

    final record = DualRecord(
      id: id,
      adapterTypId: _adapter.adapterTypeId,
      parentId: _adapter.getParentId(value),
      smallData: _adapter.toSmallData(value, id, smallEncoder),
      bigDataType: _adapter.bigDataType,
      bigData: bigDataStream ?? _adapter.getBigDataStream(value),
      bigDataSize: bigDataSize ?? _adapter.getBigDataSize(value),
    );
    await _indexedDb.add(record, onProgress: onProgress);
  }

  @override
  Future<void> addWithBigDataString(
    T value, {
    required String bigString,
    void Function(double progerss)? onProgress,
  }) async {
    if (_adapter.bigDataType != BigDataType.stringText) {
      throw Exception(
        'Your Adapter `BigDataType` is `${_adapter.bigDataType.name}`\nYou Should Use -> `$_shouldUseAddBigMethodErrorText`',
      );
    }
    final bytes = utf8.encode(bigString);
    await add(
      value,
      bigDataSize: bytes.length,
      bigDataStream: Stream.value(bytes),
      onProgress: onProgress,
    );
  }

  @override
  Future<void> addWithBigDataMap(
    T value, {
    required Map<String, dynamic> bigMap,
    void Function(double progerss)? onProgress,
  }) async {
    if (_adapter.bigDataType != BigDataType.json) {
      throw Exception(
        'Your Adapter `BigDataType` is `${_adapter.bigDataType.name}`\nYou Should Use -> `$_shouldUseAddBigMethodErrorText`',
      );
    }
    final bytes = utf8.encode(jsonEncode(bigMap));
    await add(
      value,
      bigDataSize: bytes.length,
      bigDataStream: Stream.value(bytes),
      onProgress: onProgress,
    );
  }

  @override
  Future<void> addWithBigDataFile(
    T value, {
    required String filePath,
    void Function(double progerss)? onProgress,
  }) async {
    if (_adapter.bigDataType != BigDataType.file) {
      throw Exception(
        'Your Adapter `BigDataType` is `${_adapter.bigDataType.name}`\nYou Should Use -> `$_shouldUseAddBigMethodErrorText`',
      );
    }
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File Path: `$filePath`  Not Found!');
    }
    await add(
      value,
      bigDataSize: await file.length(),
      bigDataStream: file.openRead(),
      onProgress: onProgress,
    );
  }

  @override
  Future<List<T>> getAll({int? parentId}) async {
    final result = <T>[];
    for (var meta in _indexedDb.getAll(
      parentId: parentId,
      adapterTypId: _adapter.adapterTypeId,
    )) {
      final smallDataBytes = await meta.readSmallData(_indexedDb.readRaf);
      final smallData =
          _adapter.fromSmallData(SmallDataDecoder(smallDataBytes)) as DualModel;
      // set meta
      smallData.autoId = meta.id;
      smallData.meta = meta;
      result.add(smallData as T);
      // print(meta);
    }
    return result;
  }

  @override
  Future<Stream<List<int>>?> readBigData(T value) async {
    if (_adapter.bigDataType == BigDataType.none) return null;
    // case DualModel
    final meta = (value as DualModel).meta;
    if (meta == null) return null;
    if (meta.smallDataSize == 0) return null;
    return await meta.readBigData(_indexedDb.dbFile.path);
  }

  @override
  Future<String?> readBigDataAsString(T value) async {
    if (_adapter.bigDataType == BigDataType.none &&
        _adapter.bigDataType != BigDataType.stringText) {
      return null;
    }
    // case DualModel
    final meta = (value as DualModel).meta;
    if (meta == null) return null;
    if (meta.smallDataSize == 0) return null;
    return await meta.readBigDataAsString(_indexedDb.dbFile.path);
  }

  @override
  Future<dynamic> readBigDataAsJson(T value) async {
    if (_adapter.bigDataType == BigDataType.none &&
        _adapter.bigDataType != BigDataType.json) {
      return null;
    }
    // case DualModel
    final meta = (value as DualModel).meta;
    if (meta == null) return null;
    if (meta.smallDataSize == 0) return null;
    return await meta.readBigDataAsJson(_indexedDb.dbFile.path);
  }

  @override
  Future<void> deleteAll() async {
    final ids = <int>[];
    for (var meta in _indexedDb.getAll(adapterTypId: _adapter.adapterTypeId)) {
      // adapter id မတူရင် ကျော်မယ်
      if (meta.adapterTypId != _adapter.adapterTypeId) continue;
      ids.add(meta.id);
    }
    await _indexedDb.deleteByIdList(ids);
  }

  @override
  Future<void> deleteById(int id) async {
    await _indexedDb.deleteById(id);
  }

  String get _shouldUseAddBigMethodErrorText {
    return switch (_adapter.bigDataType) {
      BigDataType.file => 'addWithBigDataFile',
      BigDataType.json => 'addWithBigDataMap',
      BigDataType.stringText => 'addWithBigDataString',
      _ => '',
    };
  }
}
