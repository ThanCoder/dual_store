import 'dart:io';

import 'package:dual_store/src/databases/dual_record.dart';
import 'package:dual_store/src/databases/record_meta.dart';
import 'package:dual_store/src/dual_config.dart';
import 'package:dual_store/src/types.dart';

class IndexedDb {
  IndexedDb();
  late File dbFile;
  late RandomAccessFile _readRaf;
  late RandomAccessFile _writeRaf;
  late DualConfig _config;

  int _lastIndex = 0;
  int _deletedCount = 0;
  int _deletedSize = 0;
  // getter
  int get lastIndex => _lastIndex;
  int get deletedCount => _deletedCount;
  int get deletedSize => _deletedSize;

  final Map<int, RecordMeta> _allRecords = {};
  final Map<int, List<RecordMeta>> _parentOfRecords = {};
  final Map<int, List<RecordMeta>> _adapterOfRecords = {};
  // get
  Map<int, RecordMeta> get allRecords => _allRecords;
  // Map<int, List<RecordMeta>> get parentOfRecords => _parentOfRecords;
  // Map<int, List<RecordMeta>> get adapterOfRecords => _adapterOfRecords;

  // get
  RandomAccessFile get readRaf => _readRaf;

  int get generatedIndex {
    _lastIndex++;
    return _lastIndex;
  }

  bool _isOpened = false;
  bool get isOpened => _isOpened;

  /// set Config
  void setConfig({required File dbFile, required DualConfig config}) {
    this.dbFile = dbFile;
    _config = config;
  }

  /// Load Database
  Future<void> load() async {
    if (isOpened) return;
    _writeRaf = await dbFile.open(mode: FileMode.append);
    _readRaf = await dbFile.open(mode: FileMode.read);
    await _loadIndexed();
    _isOpened = true;
  }

  /// Load Indexed
  Future<void> _loadIndexed() async {
    if (!dbFile.existsSync()) return;
    final size = await dbFile.length();
    await _readRaf.setPosition(0);
    while (await _readRaf.position() < size) {
      final meta = await RecordMeta.read(_readRaf);
      if (meta.flag == RecordFlag.active) {
        // active
        _allRecords[meta.id] = meta;
        if (meta.parentId != -1) {
          _parentOfRecords.putIfAbsent(meta.parentId, () => []).add(meta);
        }
        if (meta.adapterTypId != -1) {
          _adapterOfRecords.putIfAbsent(meta.adapterTypId, () => []).add(meta);
        }
      } else {
        //delete
        _deletedCount++;
        _deletedSize += meta.recordSize;
      }
      // index
      if (meta.id > lastIndex) _lastIndex = meta.id;
    }
  }

  /// get all records of meta
  Iterable<RecordMeta> getAll({int? parentId, int? adapterTypId}) {
    if (parentId != null || adapterTypId != null) {
      final results = <RecordMeta>[];
      for (var meta in _allRecords.values) {
        if (parentId != null && parentId == meta.parentId) {
          results.add(meta);
        }
        if (adapterTypId != null && adapterTypId == meta.adapterTypId) {
          results.add(meta);
        }
      }
      return results;
    }
    return _allRecords.values;
  }

  /// Add Record
  Future<void> add(
    DualRecord record, {
    void Function(double percent)? onProgress,
  }) async {
    final offset = await record.write(_writeRaf, onProgress: onProgress);
    final meta = RecordMeta.fromRecord(record, offset);

    _allRecords[record.id] = meta;
    if (meta.parentId != -1) {
      _parentOfRecords.putIfAbsent(meta.parentId, () => []).add(meta);
    }
    if (meta.adapterTypId != -1) {
      _adapterOfRecords.putIfAbsent(meta.adapterTypId, () => []).add(meta);
    }
    await _writeRaf.flush();
  }

  /// Delete Record
  Future<void> deleteById(int id) async {
    final record = _allRecords[id];
    if (record == null) throw Exception('ID `$id` Not Found!');

    await record.setDeleteMark(_writeRaf);
    // Remove RAM
    _deletedCount++;
    _deletedSize += record.recordSize;
    _allRecords.remove(id);

    await _writeRaf.flush();
    _reCalculateAllRecords();
    await mabyCompact();
  }

  /// Delete Record by id list
  Future<void> deleteByIdList(List<int> ids) async {
    for (var id in ids) {
      final record = _allRecords[id];
      if (record == null) continue;

      await record.setDeleteMark(_writeRaf);
      // Remove RAM
      _deletedCount++;
      _deletedSize += record.recordSize;
      _allRecords.remove(id);
    }

    await _writeRaf.flush();

    _reCalculateAllRecords();
    await mabyCompact();
  }

  void _reCalculateAllRecords() {
    _adapterOfRecords.clear();
    _parentOfRecords.clear();

    for (var meta in _allRecords.values) {
      if (meta.parentId != -1) {
        _parentOfRecords.putIfAbsent(meta.parentId, () => []).add(meta);
      }
      if (meta.adapterTypId != -1) {
        _adapterOfRecords.putIfAbsent(meta.adapterTypId, () => []).add(meta);
      }
    }
  }

  Future<void> close() async {
    if (!isOpened) return;
    await _writeRaf.close();
    await _readRaf.close();
    _lastIndex = 0;
    _allRecords.clear();
    _adapterOfRecords.clear();
    _parentOfRecords.clear();
    _deletedCount = 0;
    _deletedSize = 0;
    _isOpened = false;
  }

  // ** Compact **
  Future<void> mabyCompact() async {
    if (!_config.autoCompact && _deletedCount == 0) return;

    if (_deletedCount >= _config.willCompactDeletedCount ||
        _deletedSize >= _config.willCompactDeletedSize) {
      await compact(); // Trigger the maintenance
    }
  }

  Future<void> compact() async {
    if (_deletedCount == 0) return;
  }
}
