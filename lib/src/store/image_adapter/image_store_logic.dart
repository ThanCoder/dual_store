// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

mixin ImageStoreLogic on IDualStore {
  /// image adapter
  ImageDataAdapter get getImageDataAdapter {
    final ad = _adapters[ImageDataAdapter];
    if (ad == null) {
      final newAd = ImageDataAdapter();
      _adapters[ImageDataAdapter] = newAd;
      _buildinBoxs[ImageBox] = ImageBox(adapter: newAd, store: this);
      return newAd;
    }
    return ad as ImageDataAdapter;
  }

  /// Get image box (deprecated: use [imageBox] instead).
  @Deprecated('Use imageBox instead.')
  IImageBox get getImageBox => imageBox;

  ///get image box
  ///
  /// Registerd ID: `adapterId => 200`
  IImageBox get imageBox {
    getImageDataAdapter;
    return _buildinBoxs[ImageBox];
  }
}
