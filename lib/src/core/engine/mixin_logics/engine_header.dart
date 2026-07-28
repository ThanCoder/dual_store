// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/i_engine_logic.dart';

const int duHeaderLength = 6;

/// [magic(4),version(1),dbID(1)]
class DuHeader {
  final String magic;
  final int version;
  final int dbID;
  const DuHeader({required this.magic, this.version = 1, this.dbID = 0});

  @override
  String toString() =>
      'DuHeader(magic: $magic, version: $version, dbID: $dbID)';
}

mixin EngineHeader on IEngineLogic {
  /// Reader Header
  DuHeader readHeader() {
    readRaf.setPositionSync(0);
    final bytes = readRaf.readSync(6);
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
  void writeHeader(DuHeader header) {
    // check magic len
    if (header.magic.length != 4) {
      throw Exception('magic string count: `${header.magic.length} != 4 `!!!');
    }
    writeRaf.setPositionSync(0);
    final b = BytesBuilder();
    b.add(utf8.encode(header.magic));
    b.addByte(header.version);
    b.addByte(header.dbID);

    writeRaf.writeFromSync(b.takeBytes());
  }
}
