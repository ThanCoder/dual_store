import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/file_x.dart';

/// image file interface
sealed class IImageFile {
  /// extra fields
  final Map<String, dynamic> extra;

  /// parent id
  final int parentId;
  const new({required this.extra, required this.parentId});

  /// to image data class
  ImageData get toImageData;

  /// to image bytes
  Future<Uint8List> get toImageBytes;

  /// from file
  factory IImageFile.file(
    File file, {
    Map<String, dynamic> extra = const {},
    int parentId = -1,
  }) => ImageFile(file: file, parentId: parentId, extra: extra);

  /// from bytes
  factory IImageFile.bytes(
    Uint8List bytes, {
    required String name,
    required String ext,
    Map<String, dynamic> extra = const {},
    int parentId = -1,
  }) => ImageBytes(
    extra: extra,
    parentId: parentId,
    name: name,
    ext: ext,
    data: bytes,
  );

  /// image data to image file
  factory IImageFile.fromImageData(
    ImageData data, {
    String? name,
    String? ext,
    Map<String, dynamic>? extra,
    int? parentId,
    DateTime? lastModified,
  }) => ImageBytes(
    extra: extra ?? data.extra,
    parentId: parentId ?? data.parentId,
    name: name ?? data.name,
    ext: ext ?? data.ext,
    data: data.imageDataSync!,
    lastModified: lastModified ?? data.lastModified,
  );
}

/// image from file
class ImageFile extends IImageFile {
  /// file
  final File _file;

  ///constr
  const new({super.extra = const {}, super.parentId = -1, required this._file});

  @override
  ImageData get toImageData => .new(
    name: _file.name,
    ext: _file.ext,
    size: _file.size,
    lastModified: _file.lastModifiedSync(),
    extra: extra,
    parentId: parentId,
  );
  @override
  Future<Uint8List> get toImageBytes => _file.readAsBytes();
}

/// image bytes
class ImageBytes extends IImageFile {
  final String _name;
  final String _ext;
  final DateTime? _lastModified;
  final Uint8List _data;

  ///const
  new({
    required super.extra,
    required super.parentId,
    required this._name,
    required this._ext,
    this._lastModified,
    required this._data,
  });

  @override
  ImageData get toImageData => .new(
    extra: extra,
    parentId: parentId,
    name: _name,
    ext: _ext,
    size: _data.length,
    lastModified: _lastModified ?? .now(),
  );

  @override
  Future<Uint8List> get toImageBytes async => _data;
}
