import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/engine_context.dart';

class DuCtxState {
  final EngineContext _ctx;
  const DuCtxState(this._ctx);

  int get deletedCount => _ctx.deletedCount;
  int get deletedSize => _ctx.deletedSize;
  int get lastId => _ctx.lastId;
  DuHeader get header => _ctx.header;
  List<int> get adapterIds => _ctx.adapterMeta.keys.toList();
  bool get opened => _ctx.opened;
}
