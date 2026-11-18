// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

class ImageFileAdapter extends IDuBinaryMetaAdapter<ImageFile> {
  @override
  int get adapterId => 200;

  @override
  int parentId(ImageFile value) => value.parentId;

  @override
  ImageFile fromMap(Map<String, dynamic> map) {
    return .fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(ImageFile value) {
    return value.toJson();
  }
}

class ImageFile extends IImageDuModel {
  final String name;
  final String ext;
  final int size;
  final DateTime date;
  final Map<String, dynamic> extra;
  final int parentId;

  ImageFile({
    required this.name,
    required this.ext,
    required this.size,
    required this.date,
    required this.extra,
    this._data,
    this.parentId = -1,
  });
  Uint8List? _data;

  factory ImageFile.fromFile(
    File file, {
    Map<String, dynamic>? extra,
    int parentId = -1,
  }) {
    return .new(
      name: file.name,
      ext: file.ext,
      size: file.size,
      date: file.lastModifiedSync(),
      extra: extra ?? {},
      data: file.readAsBytesSync(),
      parentId: parentId,
    );
  }

  factory ImageFile.fromBytes(
    Uint8List bytes, {
    required String name,
    required String ext,
    required DateTime lastModified,
    Map<String, dynamic>? extra,
    int parentId = -1,
  }) {
    return .new(
      name: name,
      ext: ext,
      size: bytes.length,
      date: lastModified,
      extra: extra ?? {},
      data: bytes,
      parentId: parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ext': ext,
      'size': size,
      'date': date.millisecondsSinceEpoch,
      'extra': extra,
      'parentId': parentId,
    };
  }

  factory ImageFile.fromJson(Map<String, dynamic> json) {
    return ImageFile(
      name: json['name'],
      ext: json['ext'],
      size: json['size'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      extra: Map<String, dynamic>.from(json['extra']),
      parentId: json['parentId'] ?? -1,
    );
  }

  @override
  String toString() {
    return '''ImageFile(name: $name, ext: $ext, size: $size, date: $date, extra: $extra, parentId: $parentId)''';
  }
}
