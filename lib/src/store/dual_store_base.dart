import 'dart:async';

import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';
import 'package:dual_store/src/store/adapter/i_du_adapter.dart';
import 'package:dual_store/src/store/box/i_du_box.dart';
import 'package:dual_store/src/store/du_ctx_state.dart';
import 'package:dual_store/src/store/du_event_state.dart';

part 'i_dual_store.dart';
part 'adapter/i_du_model.dart';
part 'box/du_box.dart';

class DualStore extends IDualStore {
  Future<Result<bool, String>> open(String path) async {
    return await _eng.open(path);
  }

  void registerAdapter<T extends IDuModel>(IDuMetaAdapter<T> adapter) {
    final ad = _adapters[T];
    if (ad == null) {
      _adapters[T] = adapter;
      _boxs[T] = DuBox<T>(adapter: adapter, store: this);
    }
  }
}
