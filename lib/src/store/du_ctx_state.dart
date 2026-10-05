import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/engine_context.dart';

/// db state
class DuCtxState {
  final EngineContext _ctx;

  /// cost
  const DuCtxState(this._ctx);

  /// db deleted count
  ///
  /// need to compact
  int get deletedCount => _ctx.deletedCount;

  /// db deleted size
  ///
  /// need to compact
  int get deletedSize => _ctx.deletedSize;

  /// db last id
  int get lastId => _ctx.lastId;

  /// db current header
  DuHeader get header => _ctx.header;

  /// db adapter id list
  List<int> get adapterIds => _ctx.adapterMeta.keys.toList();

  /// db open or not
  bool get opened => _ctx.opened;

  /// current db path
  String get path {
    if (_ctx.onceInit) {
      return _ctx.readRaf.path;
    }
    return '';
  }
}
