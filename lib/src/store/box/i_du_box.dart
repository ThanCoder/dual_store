import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/result_t.dart';

import '../dual_store_base.dart';

abstract class IDuBox<T extends IDuModel> {
  Future<List<T>> getAll();

  /// Supported:
  /// `NoneContentWriter`,
  ///
  /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
  Future<Result<bool, String>> add(
    T value, {
    IContentWriter contentWriter = const NoneContentWriter(),
  });

  /// Supported:
  /// `NoneContentWriter`,
  ///
  /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
  Future<Result<bool, String>> update(
    int id, {
    required T value,
    IContentWriter contentWriter = const NoneContentWriter(),
  });

  ///
  /// supported: `TextRawContentReader`,`TextCompressContentReader`
  ///
  Future<Result<R, String>> getContent<R>(T value);

  // Future<void> delete(T value);
  // Future<void> updateById(int id, T value, {String? contentValue});
  Future<Result<bool, String>> deleteById(int id);
}
