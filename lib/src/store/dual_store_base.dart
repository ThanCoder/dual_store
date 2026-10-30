import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/dual_engine.dart';
import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/events/du_event_state.dart';
import 'package:dual_store/src/core/engine/logics/compact_logic.dart';
import 'package:dual_store/src/core/engine/logics/meta_info_logic.dart';
import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/core/file_x.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';
import 'package:dual_store/src/store/adapter/i_du_adapter.dart';
import 'package:dual_store/src/store/box/i_du_box.dart';
import 'package:dual_store/src/store/du_ctx_state.dart';
import 'package:dual_store/src/store/du_store_config.dart';

part 'adapter/i_du_model.dart';
part 'box/du_box.dart';
part 'i_dual_store.dart';
part 'image_adapter/image_box.dart';
part 'image_adapter/image_file_adapter.dart';
part 'image_adapter/image_store_logic.dart';
part 'search/i_search.dart';
// part 'search/binary_search.dart';
part 'search/linear_search.dart';
part 'search/search_event.dart';
part 'search/search_event_state.dart';

/// du store
class DualStore extends IDualStore with ImageStoreLogic {
  @override
  final DuStoreConfig config;

  ///init config
  new({DuStoreConfig? config}) : config = config ?? .defaultConfig();

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

  /// store header sync
  static Result<DuHeader, String> readHeaderSync(String path) {
    try {
      final raf = File(path).openSync(mode: .read);
      final res = DuHeaderIo.getHeaderSync(raf);
      raf.closeSync();
      return res;
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// store header
  static Future<Result<DuHeader, String>> readHeader(String path) async {
    try {
      final raf = await File(path).open(mode: .read);
      final res = await DuHeaderIo.getHeader(raf);
      await raf.close();
      return res;
    } catch (e) {
      return Err(e.toString());
    }
  }
}
