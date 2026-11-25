part of '../dual_store_base.dart';

/// image box interface
sealed class IImageBox {
  ///registerd adapter id
  int get adapterId;

  /// image events
  ImageBoxEventState get events;

  ///first one
  Future<ImageData?> getOne({int? parentId});

  /// get by generated id
  Future<ImageData?> getById(int generatedId, {int? parentId});

  /// find all image files
  Future<List<ImageData>> findAll(
    bool Function(ImageData file) onTest, {
    int? parentId,
  });

  /// find one image file
  Future<ImageData?> findOne(
    bool Function(ImageData file) onTest, {
    int? parentId,
  });

  ///get all images
  Stream<ImageData> streamAll({int? parentId});

  /// get all images
  Future<List<ImageData>> getAll({int? parentId});

  /// add image
  Future<Result<int, String>> add(IImageFile file, {bool diskFlush = true});

  /// IMAGE  bytes data
  Future<Uint8List?> getContent(IImageDuModel value);

  /// IMAGE  bytes data sync
  Uint8List? getContentSync(IImageDuModel value);

  /// delete image
  Future<Result<bool, String>> deleteImage(
    ImageData file, {
    bool diskFlush = true,
  });

  /// delete by id
  Future<Result<bool, String>> deleteById(int id, {bool diskFlush = true});

  /// delete all box
  ///
  /// Result (generatedId,isOk)
  Future<List<(int, bool)>> deleteAll({bool diskFlush = true, int? parentId});

  /// update by id
  Future<Result<bool, String>> updateById(
    int id, {
    required IImageFile file,
    bool diskFlush = true,
  });

  /// delete one
  Future<Result<bool, String>> deleteOne(
    bool Function(ImageData data) test, {
    bool diskFlush = true,
    int? parentId,
  });

  /// update by id
  Future<Result<bool, String>> updateOne(
    bool Function(ImageData data) test, {
    required IImageFile file,
    bool diskFlush = true,
    int? parentId,
  });
}
