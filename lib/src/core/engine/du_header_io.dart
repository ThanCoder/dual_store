import 'dart:convert';
import 'dart:io';

import 'package:dual_store/src/core/models/du_header.dart';

const int duHeaderFixedLength = 6;

class DuHeaderIo {
  /// Reader Header
  static Future<DuHeader> getHeader(RandomAccessFile raf) async {
    raf.setPositionSync(0);
    final bytes = await raf.read(6);
    if (bytes.length != 6) {
      throw Exception(
        '[EngineHeader:readHeader]: `read count: 6 -> fond count: ${bytes.length}` read error!',
      );
    }
    final magic = utf8.decode(bytes.sublist(0, 4));
    final version = bytes[4];
    final id = bytes[5];
    return DuHeader(magic: magic, version: version, dbID: id);
  }

  static DuHeader getHeaderSync(RandomAccessFile raf) {
    raf.setPositionSync(0);
    final bytes = raf.readSync(6);
    if (bytes.length != 6) {
      throw Exception(
        '[EngineHeader:readHeader]: `read count: 6 -> fond count: ${bytes.length}` read error!',
      );
    }
    final magic = utf8.decode(bytes.sublist(0, 4));
    final version = bytes[4];
    final id = bytes[5];
    return DuHeader(magic: magic, version: version, dbID: id);
  }

  ///Write Header
  static void writeHeader(DuHeader header, RandomAccessFile raf) {
    // check magic len
    if (header.magic.length != 4) {
      throw Exception('magic string count: `${header.magic.length} != 4 `!!!');
    }
    raf.setPositionSync(0);
    // ignore: deprecated_export_use
    final b = BytesBuilder(copy: false);

    b.add(utf8.encode(header.magic));
    b.addByte(header.version);
    b.addByte(header.dbID);

    raf.writeFromSync(b.takeBytes());
  }
}
