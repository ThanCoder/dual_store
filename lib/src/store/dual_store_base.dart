import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/events/du_event_state.dart';
import 'package:dual_store/src/core/engine/logics/compact_logic.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/file_x.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';
import 'package:dual_store/src/store/adapter/i_du_adapter.dart';
import 'package:dual_store/src/store/box/i_du_box.dart';
import 'package:dual_store/src/store/du_ctx_state.dart';

part 'adapter/i_du_model.dart';
part 'box/du_box.dart';
part 'i_dual_store.dart';
part 'image_adapter/image_box.dart';
part 'image_adapter/image_file_adapter.dart';
part 'image_adapter/image_store_logic.dart';

/// du store
class DualStore extends IDualStore with ImageStoreLogic {
  /// register adapter if not exists!
  ///
  /// ### Example
  ///```dart
  ///class Todo extends IDuModel {
  ///   final String title;
  ///   final bool checked;
  ///   final DateTime date;
  ///
  ///   Todo({required this.title, required this.checked, required this.date});
  /// }
  ///
  /// //want to use -> [IDuBinaryMetaAdapter,IDuJsonMetaAdapter]
  ///
  /// class TodoAdapter extends IDuBinaryMetaAdapter<Todo> {
  ///   @override
  ///   // implement adapterId
  ///   int get adapterId => throw UnimplementedError();
  ///
  ///   @override
  ///   Todo fromMap(Map<String, dynamic> map) {
  ///     // implement fromMap
  ///     throw UnimplementedError();
  ///   }
  ///
  ///   @override
  ///   Map<String, dynamic> toMap(Todo value) {
  ///     // implement toMap
  ///     throw UnimplementedError();
  ///   }
  /// }
  /// ```
  void registerAdapter<T extends IDuModel>(IDuMetaAdapter<T> adapter) {
    final ad = _adapters[T];
    if (ad == null) {
      _adapters[T] = adapter;
      _boxs[T] = DuBox<T>(adapter: adapter, store: this);
    }
  }

  /// database cleanup
  Future<Result<bool, String>> compact({
    CompactProgress? onCompactProgress,
  }) async {
    return await _eng.compact(onCompactProgress: onCompactProgress);
  }
}
