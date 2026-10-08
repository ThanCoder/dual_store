// ignore_for_file: public_member_api_docs

import 'package:dual_store/src/core/engine/writer/i_content_writer.dart';
import 'package:dual_store/src/result_t.dart';

import '../dual_store_base.dart';

abstract class IDuBox<T extends IDuModel> {
  /// first one
  Future<T?> getOne({int? parentId});

  /// first one
  Stream<T?> streamOne({int? parentId});

  /// Streams all models one by one.
  Stream<T> streamAll({int? parentId});

  /// Streams all models that match the given test.
  Stream<T> streamFind(bool Function(T val) test, {int? parentId});

  /// Streams the first matching model, then closes the stream.
  Stream<T?> streamFindOne(bool Function(T val) test, {int? parentId});

  /// Returns all models.
  Future<List<T>> getAll({int? parentId});

  /// Returns a model by id.
  Future<Result<T, String>> getById(int id);

  /// Returns the first matching model.
  Future<T?> findOne(bool Function(T value) test, {int? parentId});

  /// Returns all matching models.
  Future<List<T>> find(bool Function(T value) test, {int? parentId});

  /// Supported:
  /// `NoneContentWriter`,
  ///
  /// `TextRawContentWriter`,`JsonRawContentWriter`,`TextCompressContentWriter`
  ///
  /// Return -> `created id`
  Future<Result<int, String>> add(
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

  /// get content data or null
  Future<R?> getContentOrNull<R>(T value);

  // Future<void> delete(T value);
  // Future<void> updateById(int id, T value, {String? contentValue});
  Future<Result<bool, String>> deleteById(int id, {bool diskFlush = true});
}
