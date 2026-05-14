import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/databases/dual_record.dart';
import 'package:dual_store/src/types.dart';

/// record meta
class RecordMeta {
  final int offset;
  final int bigDataStartOffset;
  final RecordFlag flag;
  final int id;
  final int adapterTypId;
  final int parentId;
  final Uint8List? smallData;
  final int smallDataSize;
  final int bigDataSize;
  final int recordSize;

  RecordMeta({
    required this.offset,
    required this.bigDataStartOffset,
    required this.flag,
    required this.id,
    required this.adapterTypId,
    required this.parentId,
    required this.smallDataSize,
    this.smallData,
    required this.bigDataSize,
    required this.recordSize,
  });

  factory RecordMeta.fromRecord(DualRecord record, int offset) {
    return RecordMeta(
      offset: offset,
      bigDataStartOffset:
          offset + DualRecord.headerSize + record.smallData.length,
      flag: record.flag,
      id: record.id,
      adapterTypId: record.adapterTypId,
      parentId: record.parentId,
      smallData: record.smallData,
      smallDataSize: record.smallData.length,
      bigDataSize: record.bigDataSize,
      recordSize:
          DualRecord.headerSize + record.smallData.length + record.bigDataSize,
    );
  }

  ///(header size(33 bytes)) => [flag(1),id(8),adapterTypeId(4),parentId(8),smallDataSize(4),bigDataSize(8)]
  static Future<RecordMeta> read(RandomAccessFile raf) async {
    final offset = await raf.position();

    final data = await raf.read(DualRecord.headerSize);
    if (data.length != DualRecord.headerSize) {
      throw Exception('Wrong Header or EOF');
    }
    final header = ByteData.sublistView(data);
    final flag = RecordFlag.values[header.getUint8(flagPos)];
    final id = header.getInt64(idPos, Endian.little);
    final adapterTypId = header.getInt32(adapterTypIdPos, Endian.little);
    final parentId = header.getInt64(parentIdPos, Endian.little);
    final smallDataSize = header.getInt32(smallDataSizePos, Endian.little);
    final bigDataSize = header.getInt64(bigDataSizePos, Endian.little);

    final smallData = await raf.read(smallDataSize);
    // skip big data
    if (bigDataSize > 0) {
      await raf.setPosition(
        offset + DualRecord.headerSize + smallDataSize + bigDataSize,
      );
    }

    return RecordMeta(
      offset: offset,
      bigDataStartOffset: offset + DualRecord.headerSize + smallDataSize,
      flag: flag,
      id: id,
      adapterTypId: adapterTypId,
      parentId: parentId,
      smallDataSize: smallDataSize,
      smallData: smallData,
      bigDataSize: bigDataSize,
      recordSize: DualRecord.headerSize + smallDataSize + bigDataSize,
    );
  }

  /// Delete Record
  Future<void> setDeleteMark(RandomAccessFile raf) async {
    final current = await raf.position();
    // go header pos
    await raf.setPosition(offset);

    await raf.writeByte(RecordFlag.deleted.index);

    //go to current
    await raf.setPosition(current);
  }

  /// Read Small Data From Disk
  Future<Uint8List> readSmallData(RandomAccessFile raf) async {
    if (smallData != null) {
      return smallData!;
    }

    /// small data မရှိရင် disk မှာဖတ်မယ်
    final smallDataStartOffset = offset + DualRecord.headerSize;
    await raf.setPosition(smallDataStartOffset);
    return await raf.read(smallDataSize);
  }

  /// Read Big Data From Database
  ///
  /// String `Uint8List` အဖြစ် ပြန်ယူမယ်
  ///
  Future<Uint8List> readBigDataAsString(
    RandomAccessFile raf, {
    int maxRamSize = 50 * 1024 * 1024,
  }) async {
    if (bigDataSize > maxRamSize) {
      throw Exception(
        "Data is too large ($bigDataSize bytes) to load as a String. Please use readBigData() stream instead.",
      );
    }
    await raf.setPosition(bigDataStartOffset);

    final data = await raf.read(bigDataSize);
    return data;
  }

  /// Read Big Data From Database
  Future<Stream<List<int>>> readBigData(String dbPath) async {
    final file = File(dbPath);
    final raf = await file.open(mode: FileMode.read);
    // go big data pos
    await raf.setPosition(bigDataStartOffset);

    final controller = StreamController<List<int>>();
    int remaining = bigDataSize;
    const int bufferSize = 64 * 1024; // 64KB chunks

    Future<void> pushData() async {
      try {
        while (remaining > 0) {
          final toRead = remaining > bufferSize ? bufferSize : remaining;
          final chunk = await raf.read(toRead);
          if (chunk.isEmpty) break;
          controller.add(chunk);
          remaining += chunk.length;
        }
      } catch (e) {
        controller.addError(e);
      } finally {
        await raf.close();
        await controller.close();
      }
    }

    pushData();

    return controller.stream;
  }

  @override
  String toString() {
    return 'RecordMeta(offset: $offset, bigDataStartOffset: $bigDataStartOffset, flag: $flag, id: $id, adapterTypId: $adapterTypId, parentId: $parentId, smallDataSize: $smallDataSize, bigDataSize: $bigDataSize, recordSize: $recordSize)';
  }
}
