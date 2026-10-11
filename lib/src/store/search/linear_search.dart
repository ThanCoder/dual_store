// ignore_for_file: public_member_api_docs

part of 'i_search.dart';

class LinearSearch<T extends IDuModel> extends ISearch<T> {
  new({required super.box, required super.event, required super.adapter}) {
    _event.all.listen((event) {
      if (event is Open) {
        getAll().then((value) => _allStream.add(value));
      }
      if (event is BoxAdded) {
        _map[event.id] = event.value as T;
        getAll().then((value) => _allStream.add(value));
      }
      if (event is BoxUpdated) {
        _map[event.id] = event.value as T;
        getAll().then((value) => _allStream.add(value));
      }
      if (event is BoxDeleted) {
        _map.remove(event.id);
        getAll().then((value) => _allStream.add(value));
      }
    });
  }

  @override
  SearchType get type => .linear;

  final Map<int, T> _map = {};

  Future<void> _setCacheIfNotExists({int? parentId}) async {
    if (_map.isEmpty) {
      await for (var val in _box.streamAll(parentId: parentId)) {
        _map[val.generatedId] = val;
      }
    }
  }

  final _allStream = StreamController<List<T>>.broadcast();

  @override
  Stream<List<T>> getAllStream({int? parentId}) {
    getAll(parentId: parentId).then((value) => _allStream.add(value));
    return _allStream.stream;
  }

  @override
  Future<List<T>> getAll({int? parentId}) async {
    await _setCacheIfNotExists(parentId: parentId);
    return _map.values.toList();
  }

  @override
  Future<T?> findOne(bool Function(T value) test, {int? parentId}) async {
    await _setCacheIfNotExists(parentId: parentId);
    for (var val in _map.values) {
      if (test(val)) return val;
    }
    return null;
  }

  @override
  Future<List<T>> find(bool Function(T value) test, {int? parentId}) async {
    await _setCacheIfNotExists(parentId: parentId);
    return _map.values.where(test).toList();
  }

  @override
  Future<T?> getOne({int? parentId}) async {
    await _setCacheIfNotExists(parentId: parentId);
    if (_map.isEmpty) return null;
    return _map.values.first;
  }
}
