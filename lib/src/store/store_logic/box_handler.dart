part of '../du_store.dart';

mixin BoxHandler on IDuStore {
  DuBox<T> getBox<T extends IDuModel>() {
    final box = _boxs[T];
    if (box == null) {
      throw Exception('Box Not Found! in `$T`');
    }
    return box as DuBox<T>;
  }
}
