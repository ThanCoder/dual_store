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
  Future<int> add(T value) async {
    final id = _indexedDb.generatedIndex;
    final smallEncoder = SmallDataEncoder();

    final record = DualRecord(
      id: id,
      adapterTypId: _adapter.adapterTypeId,
      parentId: _adapter.getParentId(value),
      smallData: _adapter.toSmallData(value, id, smallEncoder),
      bigDataType: _adapter.bigDataType,
      bigDataSize: 0,
      bigData: Stream.empty(),
    );
    return await _indexedDb.add(record);
  }

  @override
  Future<bool> updateById(int id, T value) async {
    return await updateByIdWithBigData(id, value);
  }

  @override
  Future<bool> updateByIdWithBigMap(
    int id,
    T value, {
    required Map<String, dynamic> bigMap,
  }) async {
    return await updateByIdWithBigString(
      id,
      value,
      bigString: jsonEncode(bigMap),
    );
  }

  @override
  Future<bool> updateByIdWithBigString(
    int id,
    T value, {
    required String bigString,
  }) async {
    if (_indexedDb.config.useBigDataGzipEncoder) {
      final bytes = gzip.encode(utf8.encode(bigString));
      return await updateByIdWithBigData(
        id,
        value,
        bigDataSize: bytes.length,
        bigDataStream: Stream.value(bytes),
      );
    } else {
      final bytes = utf8.encode(bigString);
      return await updateByIdWithBigData(
        id,
        value,
        bigDataSize: bytes.length,
        bigDataStream: Stream.value(bytes),
      );
    }
  }

  @override
  Future<bool> updateByIdWithBigData(
    int id,
    T value, {
    Stream<List<int>>? bigDataStream,
    int? bigDataSize,
    void Function(double progerss)? onProgress,
  }) async {
    final smallEncoder = SmallDataEncoder();

    final record = DualRecord(
      id: id,
      adapterTypId: _adapter.adapterTypeId,
      parentId: _adapter.getParentId(value),
      smallData: _adapter.toSmallData(value, id, smallEncoder),
      bigDataType: _adapter.bigDataType,
      bigDataSize: bigDataSize ?? 0,
      bigData: bigDataStream ?? Stream.empty(),
    );
    return await _indexedDb.updateById(id, record);
  }

  @override
  Future<int> addWithBigData(
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
      bigData: bigDataStream ?? Stream.empty(),
      bigDataSize: bigDataSize ?? 0,
    );
    await _indexedDb.add(record, onProgress: onProgress);
    return id;
  }

  @override
  Future<int> addWithBigDataString(T value, {required String bigString}) async {
    if (_adapter.bigDataType != BigDataType.stringText) {
      throw Exception(
        'Your Adapter `BigDataType` is `${_adapter.bigDataType.name}`\nYou Should Use -> `$_shouldUseAddBigMethodErrorText`',
      );
    }
    if (_indexedDb.config.useBigDataGzipEncoder) {
      final bytes = gzip.encode(utf8.encode(bigString));
      return await addWithBigData(
        value,
        bigDataSize: bytes.length,
        bigDataStream: Stream.value(bytes),
      );
    } else {
      final bytes = utf8.encode(bigString);
      return await addWithBigData(
        value,
        bigDataSize: bytes.length,
        bigDataStream: Stream.value(bytes),
      );
    }
  }

  @override
  Future<int> addWithBigDataMap(
    T value, {
    required Map<String, dynamic> bigMap,
  }) async {
    if (_adapter.bigDataType != BigDataType.stringText) {
      throw Exception(
        'Your Adapter `BigDataType` is `${_adapter.bigDataType.name}`\nYou Should Use -> `$_shouldUseAddBigMethodErrorText`',
      );
    }
    return await addWithBigDataString(value, bigString: jsonEncode(bigMap));
  }

  @override
  Future<int> addWithBigDataFile(
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
    return await addWithBigData(
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
  Future<T?> getOne(FindFuncCallback<T> test, {int? parentId}) async {
    for (var val in await getAll(parentId: parentId)) {
      if (test(val)) return val;
    }
    return null;
  }

  @override
  Future<List<T>> find(FindFuncCallback<T> test, {int? parentId}) async {
    final results = <T>[];
    for (var val in await getAll(parentId: parentId)) {
      if (test(val)) {
        results.add(val);
      }
    }
    return results;
  }

  @override
  Stream<T?> getOneStream(FindFuncCallback<T> test, {int? parentId}) async* {
    await for (var val in getAllStream(parentId: parentId)) {
      if (test(val)) {
        yield val;
        return;
      }
    }
    yield null;
  }

  @override
  Stream<T> getAllStream({int? parentId}) async* {
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
      yield (smallData as T);
      // print(meta);
    }
  }

  @override
  Stream<List<T>> findStream(FindFuncCallback<T> test, {int? parentId}) async* {
    final results = <T>[];

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
      results.add(smallData as T);
      // print(meta);
    }
    yield results;
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
    // print('id: ${meta.id}- meta: $meta');

    final result = await meta.readBigDataAsString(_indexedDb.readRaf);
    if (_indexedDb.config.useBigDataGzipEncoder) {
      return utf8.decode(gzip.decode(result));
    }
    return utf8.decode(result);
  }

  @override
  Future<Map<String, dynamic>?> readBigDataAsMap(
    T value, {
    void Function(String error)? onError,
  }) async {
    try {
      final str = await readBigDataAsString(value);
      if (str == null) return null;
      final map = jsonDecode(str);

      return Map<String, dynamic>.from(map);
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
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
  Future<void> deleteByIdList(List<int> ids) async {
    await _indexedDb.deleteByIdList(ids);
  }

  @override
  Future<bool> deleteById(int id) async {
    return await _indexedDb.deleteById(id);
  }

  String get _shouldUseAddBigMethodErrorText {
    return switch (_adapter.bigDataType) {
      BigDataType.file => 'addWithBigDataFile',
      BigDataType.stringText => 'addWithBigDataString,addWithBigDataMap',
      BigDataType.none =>
        '''  
  in -> extends DualAdapter<$T>
  
  @override
  // TODO: implement bigDataType
  BigDataType get bigDataType => super.bigDataType;\n''',
    };
  }
}
