// ignore_for_file: public_member_api_docs

part of '../dual_store_base.dart';

mixin ImageStoreLogic on IDualStore {
  /// image adapter
  ImageFileAdapter get getImageFileAdapter {
    final ad = _adapters[ImageFileAdapter];
    if (ad == null) {
      final newAd = ImageFileAdapter();
      _adapters[ImageFileAdapter] = newAd;
      _buildinBoxs[ImageBox] = ImageBox(adapter: newAd, store: this);
      return newAd;
    }
    return ad as ImageFileAdapter;
  }

  ///image box
  ImageBox get getImageBox {
    getImageFileAdapter;
    return _buildinBoxs[ImageBox];
  }
}
