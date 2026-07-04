import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/databases/dual_record.dart';
import 'package:dual_store/src/databases/record_meta.dart';
import 'package:dual_store/src/dual_config.dart';
import 'package:dual_store/src/types.dart';

class IndexedDb {
  IndexedDb();
  late File dbFile;
  late RandomAccessFile _readRaf;
  late RandomAccessFile _writeRaf;
  late DualConfig config;

  int _lastIndex = 0;
  int _deletedCount = 0;
  int _deletedSize = 0;
  // getter
  int get lastIndex => _lastIndex;
  int get deletedCount => _deletedCount;
  int get deletedSize => _deletedSize;

  final Map<int, RecordMeta> _allRecords = {};
  // get
  Map<int, RecordMeta> get allRecords => _allRecords;

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
    this.config = config;
  }

  /// Load Database
  Future<void> load() async {
    if (isOpened) return;
    _writeRaf = dbFile.openSync(mode: FileMode.append);
    _readRaf = dbFile.openSync(mode: FileMode.read);
    _loadIndexed();
    _isOpened = true;
  }

  /// Load Indexed
  void _loadIndexed() {
    if (!dbFile.existsSync()) return;
    final size = dbFile.lengthSync();
    _readRaf.setPositionSync(0);
    while (_readRaf.positionSync() < size) {
      final meta = RecordMeta.read(_readRaf);
      if (meta.flag == RecordFlag.active) {
        // active
        _allRecords[meta.id] = meta;
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
    // logic ကို functional approach နဲ့ ရေးတာ ပိုရှင်းပါတယ်
    return _allRecords.values.where((meta) {
      // parentId ပေးထားရင် ကိုက်ညီရမယ်
      final matchParent = parentId == null || meta.parentId == parentId;

      // adapterTypId ပေးထားရင် ကိုက်ညီရမယ်
      final matchAdapter =
          adapterTypId == null || meta.adapterTypId == adapterTypId;

      return matchParent && matchAdapter;
    });
  }

  /// get all records of meta
  int getAllCount({int? parentId, int? adapterTypId}) {
    // logic ကို functional approach နဲ့ ရေးတာ ပိုရှင်းပါတယ်
    return _allRecords.values.where((meta) {
      // parentId ပေးထားရင် ကိုက်ညီရမယ်
      final matchParent = parentId == null || meta.parentId == parentId;

      // adapterTypId ပေးထားရင် ကိုက်ညီရမယ်
      final matchAdapter =
          adapterTypId == null || meta.adapterTypId == adapterTypId;

      return matchParent && matchAdapter;
    }).length;
  }

  /// Add Record
  /// Return ->  `[Added Record.id]`
  Future<int> add(
    DualRecord record, {
    void Function(double percent)? onProgress,
  }) async {
    final offset = await record.write(_writeRaf, onProgress: onProgress);
    final meta = RecordMeta.fromRecord(record, offset);

    _allRecords[record.id] = meta;
    await _writeRaf.flush();

    return record.id;
  }

  /// Add Record
  Future<bool> updateById(
    int id,
    DualRecord record, {
    void Function(double percent)? onProgress,
  }) async {
    if (!await deleteById(id, writeFlush: false)) return false;

    final offset = await record.write(_writeRaf, onProgress: onProgress);
    final meta = RecordMeta.fromRecord(record, offset);

    _allRecords[record.id] = meta;
    await _writeRaf.flush();
    return true;
  }

  /// Delete Record
  Future<bool> deleteById(int id, {bool writeFlush = true}) async {
    final record = _allRecords[id];
    // if (record == null) throw Exception('ID `$id` Not Found!');
    if (record == null) {
      print('ID `$id` Not Found!');
      return false;
    }

    await record.setDeleteMark(_writeRaf);
    // Remove RAM
    _deletedCount++;
    _deletedSize += record.recordSize;
    _allRecords.remove(id);

    if (writeFlush) {
      await _writeRaf.flush();
      await mabyCompact();
    }
    return true;
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

    await mabyCompact();
  }

  Future<void> close() async {
    if (!isOpened) return;
    await _clearCache();
  }

  // ** Compact **
  Future<void> mabyCompact() async {
    if (!config.autoCompact && _deletedCount == 0) return;

    if (_deletedCount >= config.willCompactDeletedCount ||
        _deletedSize >= config.willCompactDeletedSize) {
      await compact(); // Trigger the maintenance
    }
  }

  /// When Database Deleted Size Over More Than > Compact Calculate. Will Compact
  Future<void> compact() async {
    if (_deletedCount == 0) return;
    final compactFile = File('${dbFile.path}.compact-tem');
    final compactRaf = await compactFile.open(mode: FileMode.write);

    // write header
    // await compactRaf.writeFrom(utf8.encode(magic));
    // await compactRaf.writeByte(version);

    final bufferSize = config.compactBufferSize;
    final buffer = Uint8List(bufferSize);

    for (var meta in _allRecords.values) {
      // go meta header
      await readRaf.setPosition(meta.offset);
      int bytesToRead = meta.recordSize;

      while (bytesToRead > 0) {
        final currentReadSize = bytesToRead > bufferSize
            ? bufferSize
            : bytesToRead;

        final bytesRead = await readRaf.readInto(buffer, 0, currentReadSize);
        // ရေးထည့်မယ်
        await compactRaf.writeFrom(buffer, 0, bytesRead);

        //ဖတ်ပြီးသားကို နှုတ်ချထား
        bytesToRead -= currentReadSize;
      }
    }

    await compactRaf.close();
    //rename
    if (dbFile.existsSync()) {
      await dbFile.delete();
    }
    await compactFile.rename(dbFile.path);
    await _clearCache();
    await load();
  }

  Future<void> _clearCache() async {
    await _writeRaf.close();
    await _readRaf.close();
    _allRecords.clear();
    _lastIndex = 0;
    _deletedCount = 0;
    _deletedSize = 0;
    _isOpened = false;
  }
}
