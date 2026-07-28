import 'dart:typed_data';

import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/models/du_record.dart';
import 'package:dual_store/src/core/models/meta_info.dart';
import 'package:dual_store/src/store/adapter/i_du_adapter.dart';
import 'package:dual_store/src/store/adapter/i_du_model.dart';

part 'i_du_store.dart';
part 'store_logic/adapter_handler.dart';
part 'box/du_box.dart';
part 'store_logic/box_handler.dart';
part 'store_logic/engine_handler.dart';

class DuStore extends IDuStore with AdapterHandler, BoxHandler, EngineHandler {
  @override
  late DualEngine _engine;

  @override
  late MetaInfo _metaInfo;

  @override
  final Map<Type, DuBox> _boxs = {};
  @override
  final Map<Type, IDuAdapter> _adapters = {};

  @override
  int get _generated {
    _metaInfo.lastId += 1;
    return _metaInfo.lastId;
  }

  @override
  Future<void> open(String path) async {
    _engine = DualEngine();
    _engine.open(path);
    _metaInfo = _engine.getMetaInfo();
  }

  Future<Uint8List?> getContentById(int id) async {
    final meta = _metaInfo.allMeta[id];
    if (meta == null || meta.dataSize == 0) return null;
    return _engine.getDataFromMeta(meta);
  }

  @override
  Future<void> close() async {
    _engine.close();
  }
}
