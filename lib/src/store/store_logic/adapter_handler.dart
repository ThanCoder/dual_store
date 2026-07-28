part of '../du_store.dart';

mixin AdapterHandler on IDuStore {
  /// ### Register Adapter
  void registerAdapter<T extends IDuModel>(IDuAdapter<T> adpater) {
    if (T == dynamic) {
      throw ArgumentError('dynamic type is not allowed.');
    }
    //type အရင်စစ်
    if (_adapters.containsKey(T)) {
      throw StateError('Adapter for $T is already registered.');
    }
    // _adapters[T] = adpater;
    _adapters[T] = adpater;
    _boxs[T] = DuBox<T>(engine: _engine, adapter: adpater, store: this);
  }

  /// ### Register Adapter if not exists.
  void registerAdapterNotExists<T extends IDuModel>(IDuAdapter<T> adpater) {
    if (T == dynamic) {
      throw ArgumentError('dynamic type is not allowed.');
    }
    //type အရင်စစ်
    if (_adapters.containsKey(T)) {
      return;
    }
    _adapters[T] = adpater;
    _boxs[T] = DuBox<T>(engine: _engine, adapter: adpater, store: this);
  }
}
