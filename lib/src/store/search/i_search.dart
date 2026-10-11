// ignore_for_file: unused_field, public_member_api_docs

import 'dart:async';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/engine/events/du_event_state.dart';
import 'package:dual_store/src/store/box/i_du_box.dart';

// part 'binary_search.dart';
part 'linear_search.dart';
part 'search_event.dart';
part 'search_event_state.dart';

enum SearchType {
  linear,
  //binary
}

///search
abstract class ISearch<T extends IDuModel> {
  SearchType get type;
  final IDuBox<T> _box;
  final IDuMetaAdapter<T> _adapter;
  final DuBoxEvent _event;
  new({required this._box, required this._event, required this._adapter});

  final _evCon = StreamController<SearchEvent>.broadcast();
  late final events = SearchEventState<T>(
    all: _evCon.stream,
    error: _evCon.stream.whereType<Error>(),
    add: _evCon.stream.whereType<Add<T>>(),
    update: _evCon.stream.whereType<Update<T>>(),
    delete: _evCon.stream.whereType<Delete<T>>(),
  );

  /// cached list
  Future<List<T>> getAll({int? parentId});

  /// auto update -> `add`,`update`,`delete`
  Stream<List<T>> getAllStream({int? parentId});

  /// Returns the first matching model.
  Future<T?> findOne(bool Function(T value) test, {int? parentId});

  /// Returns all matching models.
  Future<List<T>> find(bool Function(T value) test, {int? parentId});

  /// get first one
  Future<T?> getOne({int? parentId});
}
