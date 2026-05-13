import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/types.dart';

const flagPos = 0;
const idPos = 1;
const adapterTypIdPos = 9;
const parentIdPos = 13;
const smallDataSizePos = 21;
const bigDataSizePos = 25;

///Write Dual Record
class DualRecord {
  final RecordFlag flag;
  final int id;
  final int adapterTypId;
  final int parentId;
  final int bigDataSize;
  final Uint8List smallData;
  final BigDataType bigDataType;
  final Stream<List<int>> bigData;

  const DualRecord({
    this.flag = RecordFlag.active,
    required this.id,
    required this.adapterTypId,
    required this.parentId,
    required this.smallData,
    required this.bigDataSize,
    required this.bigDataType,
    required this.bigData,
  });

  ///(header size(33 bytes)) => [flag(1),id(8),adapterTypeId(4),parentId(8),smallDataSize(4),bigDataSize(8)]
  static int headerSize = 33;

  ///Write Data
  /// Return `header start offset`
  ///
  Future<int> write(
    RandomAccessFile raf, {
    void Function(double percent)? onProgress,
  }) async {
    final offset = await raf.position();
    final header = ByteData(headerSize); //33
    header.setUint8(flagPos, flag.index);
    header.setInt64(idPos, id, Endian.little);
    header.setInt32(adapterTypIdPos, adapterTypId, Endian.little);
    header.setInt64(parentIdPos, parentId, Endian.little);
    header.setInt32(smallDataSizePos, smallData.length, Endian.little);
    header.setInt64(bigDataSizePos, bigDataSize, Endian.little);

    final builder = BytesBuilder(copy: false);
    builder.add(header.buffer.asUint8List());
    builder.add(smallData);
    // write
    await raf.writeFrom(builder.takeBytes());

    // write big data
    if (bigDataSize > 0) {
      int writtenBytes = 0;
      int lastPercent = -1;

      //string,json,file
      await for (var chunk in bigData) {
        await raf.writeFrom(chunk);
        // Progress တွက်ချက်ခြင်း
        writtenBytes += chunk.length;
        int currentPercent = ((writtenBytes / bigDataSize) * 100).toInt();
        if (currentPercent != lastPercent) {
          // ၁ ရာခိုင်နှုန်း တက်မှ တစ်ခါ UI ကို ပြောမယ်
          lastPercent = currentPercent;
          onProgress?.call(currentPercent.toDouble());
        }
      }
    }

    return offset;
  }
}
