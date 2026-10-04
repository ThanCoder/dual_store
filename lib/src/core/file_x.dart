// ignore_for_file: public_member_api_docs

import 'dart:io';

extension FileX on File {
  String get name {
    return path.split('/').last;
  }

  String get ext {
    return name.split('.').last;
  }

  int get size {
    return lengthSync();
  }
}
