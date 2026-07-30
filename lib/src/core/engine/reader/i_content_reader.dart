import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/interfaces/types.dart';

abstract class IContentReader {
  DuContentFlag get contentFlag;
  DuContentDataType get dataType;
  int get size;

  Future<void> copyTo(RandomAccessFile target);

  Stream<Uint8List> openRead();

  Future<Uint8List> readAll();
}

// abstract class IContentReader {
//   DuContentFlag get contentFlag;
//   DuContentDataType get dataType;
//   int get size;

//   Stream<Uint8List> openRead();

//   Future<void> copyTo(RandomAccessFile target);
// }
