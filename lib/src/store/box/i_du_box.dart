import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/result_t.dart';

import '../dual_store_base.dart';

abstract class IDuBox<T extends IDuModel> {
  Future<Result<List<T>, String>> getAll();

  Future<Result<T, String>> getById(int id);
  Future<Result<T, String>> getOne(bool Function(T val) onTest);

  /// Supported:
  /// `NoneContentWriter`,
  ///
  /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
  Future<Result<bool, String>> add(
    T value, {

    /// Supported:
    /// `NoneContentWriter`,
    ///
    /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
    IContentWriter contentWriter = const NoneContentWriter(),
    bool diskFlush = true,
  });

  /// Supported:
  /// `NoneContentWriter`,
  ///
  /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
  Future<Result<bool, String>> update(
    int id, {
    required T value,

    /// Supported:
    /// `NoneContentWriter`,
    ///
    /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
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
