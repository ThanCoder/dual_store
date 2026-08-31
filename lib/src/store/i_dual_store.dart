part of 'dual_store_base.dart';

sealed class IDualStore {
  //*************Adapter******************** */
  final _adapters = <Type, IDuMetaAdapter>{};
  final _boxs = <Type, DuBox>{};

  DuBox<T> getBox<T extends IDuModel>() {
    final box = _boxs[T];
    if (box == null) {
      throw Exception('Need To Register $T Adapter!');
    }
    return box as DuBox<T>;
  }

  //*************Engine******************** */
  final _eng = DualEngine();

  Future<Result<bool, String>> open(String path) async {
    return await _eng.open(path);
  }

  Result<bool, String> openSync(String path) {
    return _eng.openSync(path);
  }

  Future<Result<bool, String>> changePath(String path) async {
    return await _eng.changePath(path);
  }

  Result<bool, String> changePathSync(String path) {
    return _eng.changePathSync(path);
  }

  Future<Result<bool, String>> close() async {
    return await _eng.close();
  }

  Result<bool, String> closeSync() {
    return _eng.closeSync();
  }

  /// flushes the contents of the file to disk.
  Future<Result<bool, String>> flush() async {
    return await _eng.flush();
  }

  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> flushSync() {
    return _eng.flushSync();
  }

  //*************Events******************** */
  late final DuEventState events = _eng.events;

  //*************State******************** */
  late final DuCtxState state = DuCtxState(_eng.ctx);
}
