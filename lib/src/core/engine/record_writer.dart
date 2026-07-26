import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/interfaces/i_engine.dart';
import 'package:dual_store/src/interfaces/i_writer.dart';

class RecordWriter {
  final RandomAccessFile _writeRaf;
  RecordWriter(this._writeRaf);

  Future<void> write(
    IRecordWriter writer, {
    OnWriterProgerssCallback? onProgress,
  }) async {
    final startPosition = _writeRaf.positionSync();

    // error တက်ခဲ့ရင်တောင် ဖိုင် Pointer မညပ်နေစေဖို့ try-finally သုံးတာ ပိုစိတ်ချရပါတယ်
    try {
      // ၁။ write header
      _writeRaf.writeFromSync(writer.getHeaderBytes());

      final totalDataSize = writer.totalDataSize;

      // ၂။ write data
      int realDataSize = 0;
      await for (var chunk in writer.writeChunks()) {
        _writeRaf.writeFromSync(chunk);
        realDataSize += chunk.length;

        // progress
        if (totalDataSize != null && totalDataSize > 0 && onProgress != null) {
          final progress = realDataSize / totalDataSize;
          onProgress(progress.clamp(0.0, 1.0));
        }
      }

      // ၃။ end pos
      final endPosition = _writeRaf.positionSync();

      // ၄။ size ကို ပြန်ပြင်မယ်
      final dataSizeOffset = startPosition + writer.getSizePositionOffset;
      _writeRaf.setPositionSync(dataSizeOffset);

      final sizeLable = ByteData(4)
        ..setInt32(0, realDataSize, BaseRecordWriter.endian);
      _writeRaf.writeFromSync(sizeLable.buffer.asUint8List());

      // ၅။ ရေးပြီးသွားတဲ့ အဆုံးသတ်နေရာဆီ ပုံမှန်အတိုင်း ပြန်ပို့ပေးမယ်
      _writeRaf.setPositionSync(endPosition);
    } catch (e) {
      // error ဖြစ်ခဲ့ရင် နောက်တစ်ကြိမ် write ရင် အဆင်ပြေအောင်
      // ဖိုင်ရဲ့ လက်ရှိအဆုံးသတ် (EOF) နေရာဆီ pointer ကို ရွှေ့ပေးလိုက်ပါတယ်
      _writeRaf.setPositionSync(_writeRaf.lengthSync());
      rethrow; // error ကို အပြင်က သိအောင် ပြန် push ပေးမယ်
    }
  }
}
