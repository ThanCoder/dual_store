part of 'du_store.dart';

abstract class IDuStore {
  Future<void> open(String path);
  Future<void> close();

  DualEngine get _engine;
  Map<Type, DuBox> get _boxs;
  Map<Type, IDuAdapter> get _adapters;

  MetaInfo get _metaInfo;
  int get _generated;
}
