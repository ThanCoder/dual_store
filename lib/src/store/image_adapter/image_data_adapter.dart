// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

class ImageDataAdapter extends IDuBinaryMetaAdapter<ImageData> {
  @override
  int get adapterId => 200;

  @override
  int parentId(ImageData value) => value.parentId;

  @override
  ImageData fromMap(Map<String, dynamic> map) {
    return .fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(ImageData value) {
    return value.toJson();
  }
}

class ImageData extends IImageDuModel {
  final String name;
  final String ext;
  final int size;
  final DateTime lastModified;
  final Map<String, dynamic> extra;
  final int parentId;

  new({
    required this.name,
    required this.ext,
    required this.size,
    required this.lastModified,
    required this.extra,
    required this.parentId,
  });

  ImageData copyWith({
    String? name,
    String? ext,
    int? size,
    DateTime? lastModified,
    Map<String, dynamic>? extra,
    int? parentId,
  }) {
    return ImageData(
      name: name ?? this.name,
      ext: ext ?? this.ext,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      extra: extra ?? this.extra,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ext': ext,
      'size': size,
      'lastModified': lastModified.millisecondsSinceEpoch,
      'extra': extra,
      'parentId': parentId,
    };
  }

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      name: json['name'],
      ext: json['ext'],
      size: json['size'],
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified']),
      extra: Map<String, dynamic>.from(json['extra']),
      parentId: json['parentId'],
    );
  }

  @override
  String toString() {
    return '''ImageData(name: $name, ext: $ext, size: $size, lastModified: $lastModified, extra: $extra, parentId: $parentId)''';
  }
}
