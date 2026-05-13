import 'dart:io';

import 'package:dual_store/src/boxs/dual_box.dart';
import 'package:dual_store/src/databases/indexed_db.dart';
import 'package:dual_store/src/dual_config.dart';
import 'package:dual_store/src/interfaces/dual_adapter.dart';
import 'package:dual_store/src/interfaces/dual_model.dart';

class DualStore {
  static DualStore? _instance;

  /// SingleTon Pattern
  DualStore getInstance() {
    _instance ??= DualStore();
    return _instance!;
  }

  /// ** Register Adapter **
  final Map<Type, DualAdapter> _adapters = {};
  final Map<Type, DualBox> _boxs = {};

  /// Register Adapter Not Exists
  void registerAdapterNotExists<T extends DualModel>(DualAdapter<T> adapter) {
    final ids = _adapters.values.map((e) => e.adapterTypeId).toSet();
    if (ids.contains(adapter.adapterTypeId)) {
      throw Exception(
        """ Duplicate Adapter: `${adapter.runtimeType}` Unique id detected: `${adapter.adapterTypeId}`\n--- Please Changed ---
        @override
        int get adapterTypeId => `${adapter.adapterTypeId}`; <<<-----
        """,
      );
    }
    _adapters[T] = adapter;
    _boxs[T] = DualBox<T>(adapter, _indexedDb);
  }

  ///
  /// ### Get Registered Adapter`<T>`
  ///
  DualAdapter<T> getAdapter<T extends DualModel>() {
    final adapter = _adapters[T];
    if (adapter == null) {
      throw Exception('No Adapter Registerd for type `$T`');
    }
    return adapter as DualAdapter<T>;
  }

  ///
  /// ### Get Box`<T>`
  ///
  DualBox<T> getBox<T extends DualModel>() {
    final box = _boxs[T];
    if (box == null) {
      throw Exception('No Adapter Registerd for type `$T`!');
    }
    return box as DualBox<T>;
  }

  final _indexedDb = IndexedDb();

  /// Database Open
  ///
  /// if `isOpened == true` ? ->  Not Open Database!.
  ///
  /// You Need To Call ->  `close` Method!.
  ///
  Future<void> open(String dbPath, {DualConfig? config}) async {
    if (isOpened) return;
    _indexedDb.setConfig(dbFile: File(dbPath), config: config ?? DualConfig());
    await _indexedDb.load();
  }

  bool get isOpened => _indexedDb.isOpened;

  int get lastIndex => _indexedDb.lastIndex;
  int get deletedCount => _indexedDb.deletedCount;
  int get deletedSize => _indexedDb.deletedSize;

  /// close database
  Future<void> close() async {
    await _indexedDb.close();
  }
}
