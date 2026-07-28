import 'dart:io';

abstract class IEngineLogic {
  RandomAccessFile get writeRaf;
  RandomAccessFile get readRaf;

  void open(String path);
  void flush();
  void close();
}
