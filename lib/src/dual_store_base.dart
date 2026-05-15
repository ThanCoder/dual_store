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
    final existingAdapter = _adapters[T];

    // ၁။ Type တူနေသလား အရင်စစ်မယ်
    if (existingAdapter != null) {
      // Type လည်းတူ၊ ID လည်းတူနေရင် ဘာမှမလုပ်ဘဲ return ပြန်မယ်
      if (existingAdapter.adapterTypeId == adapter.adapterTypeId) {
        // print('ရှိနှင့်ပြီးသားဖြစ်၍ ကျော်သွားပါမည်');
        return;
      }
    }

    // ၂။ Type မတူပေမယ့် ID တူနေတာ ရှိမရှိ စစ်မယ် (ID duplication check)
    final allIds = _adapters.values.map((e) => e.adapterTypeId).toSet();
    if (allIds.contains(adapter.adapterTypeId)) {
      throw Exception(
        """Duplicate Adapter ID: Unique id `${adapter.adapterTypeId}` is already used by another type.
        Please change the adapterTypeId for `${adapter.runtimeType}`.
        """,
      );
    }

    // ၃။ အပေါ်က အခြေအနေတွေ မရှိရင် Register လုပ်မယ်
    _adapters[T] = adapter;
    _boxs[T] = DualBox<T>(adapter, _indexedDb);
    // print('${T.toString()} ကို register လုပ်ပြီးပါပြီ');
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

  int get allCount => _indexedDb.allRecords.length;

  /// Get All Record Count
  int getAllCount({int? parentId, int? adapterTypId}) {
    return _indexedDb.getAllCount(
      parentId: parentId,
      adapterTypId: adapterTypId,
    );
  }

  /// close database
  Future<void> close() async {
    await _indexedDb.close();
  }

  ///Maby Compact
  Future<void> mabyCompact() async {
    await _indexedDb.mabyCompact();
  }

  Future<void> compact() async {
    await _indexedDb.compact();
  }
}
