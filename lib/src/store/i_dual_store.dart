part of 'dual_store_base.dart';

sealed class IDualStore {
  //*************Adapter******************** */
  final _adapters = <Type, IDuMetaAdapter>{};
  final _boxs = <Type, DuBox>{};

  /// get box model
  ///
  /// ```dart
  /// final box = store.getBox<Todo>();
  /// print(box);
  ///
  DuBox<T> getBox<T extends IDuModel>() {
    final box = _boxs[T];
    if (box == null) {
      throw Exception('Need To Register $T Adapter!');
    }
    return box as DuBox<T>;
  }

  /// get box model nullable
  ///
  /// ```dart
  /// final box = store.getBoxOrNull<Todo>();
  /// print(box?);
  ///
  DuBox<T>? getBoxOrNull<T extends IDuModel>() {
    final box = _boxs[T];
    if (box != null) {
      return box as DuBox<T>;
    }
    return null;
  }

  /// get adapter
  ///
  /// ```dart
  /// final ad = store.getAdapter<Todo>();
  /// print(ad);
  ///
  /// ```
  IDuMetaAdapter<T> getAdapter<T extends IDuModel>() {
    final ad = _adapters[T];
    if (ad == null) {
      throw Exception('Need To Register $T Adapter!');
    }
    return ad as IDuMetaAdapter<T>;
  }

  /// get adapter nullable
  ///
  /// ```dart
  /// final ad = store.getAdapterOrNull<Todo>();
  /// print(ad?);
  ///
  /// ```
  IDuMetaAdapter<T>? getAdapterOrNull<T extends IDuModel>() {
    final ad = _adapters[T];
    if (ad != null) {
      return ad as IDuMetaAdapter<T>;
    }
    return null;
  }

  //*************Engine******************** */
  final _eng = DualEngine();

  Future<Result<bool, String>> open(String path) async {
    return await _eng.open(path);
  }

  ///result
  ///
  ///opened -> false
  ///
  ///it will opened -> true
  ///
  ///if error -> error String
  ///
  Future<Result<bool, String>> openIfNotOpened(String path) async {
    if (_eng.ctx.opened) return Ok(false);
    return await _eng.open(path);
  }

  String get path => _eng.ctx.readRaf.path;
  bool get opened => _eng.ctx.opened;

  Future<Result<bool, String>> changePath(String path) async {
    return await _eng.changePath(path);
  }

  Future<Result<bool, String>> reload() async {
    return await _eng.reload();
  }

  Future<Result<bool, String>> reloadIfNotOpened() async {
    return await _eng.reloadIfNotOpened();
  }

  /// close database
  Future<Result<bool, String>> close() async {
    return await _eng.close();
  }

  /// flushes the contents of the file to disk.
  Future<Result<bool, String>> flush() async {
    return await _eng.flush();
  }

  //*************Events******************** */
  late final DuEventState events = _eng.events;

  //*************State******************** */
  late final DuCtxState state = DuCtxState(_eng.ctx);
}
