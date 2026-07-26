import 'dart:async';
import 'dart:io';

import 'package:dual_store/src/interfaces/i_meta.dart';
import 'package:dual_store/src/interfaces/i_writer.dart';

class RecordStreamReader {
  final RandomAccessFile _readRaf;
  final int bufferChunkSize;
  RecordStreamReader(this._readRaf, {this.bufferChunkSize = 65536});

  Stream<List<int>> readData(IMeta meta) {
    // 💡 Stream ကို Broadcast မဟုတ်ဘဲ Single-subscription ဖြစ်အောင်
    // instantiation လုပ်ထားတာ မှန်ကန်ပါတယ် (ဖိုင်ဒေတာကို တစ်ယောက်ပဲ ဖတ်သင့်လို့ပါ)
    final controller = StreamController<List<int>>();

    Future<void> streamPayload() async {
      try {
        final dataStartPos =
            meta.recordOffset + BaseRecordWriter.recordHeaderSize;
        _readRaf.setPositionSync(dataStartPos);

        int bytesRemaining = meta.dataSize;

        // controller.isClosed ကော controller.hasListener ကိုပါ စစ်ရင် ပိုစိတ်ချရပါတယ်
        while (bytesRemaining > 0 &&
            !controller.isClosed &&
            controller.hasListener) {
          int sizeToRead = bytesRemaining > bufferChunkSize
              ? bufferChunkSize
              : bytesRemaining;
          final chunk = _readRaf.readSync(sizeToRead);

          if (chunk.isEmpty) break;

          controller.add(chunk);
          bytesRemaining -= chunk.length;
        }
      } catch (e) {
        // သုံးတဲ့လူဆီ error အကြောင်းကြားမယ်
        if (!controller.isClosed) {
          controller.addError(e);
        }
      } finally {
        // ဘာပဲဖြစ်ဖြစ် stream ကို ပိတ်ပေးမယ်
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    }

    controller.onListen = streamPayload;

    // 💡 အကယ်၍ သုံးတဲ့လူက အလယ်ကနေ ဖတ်တာ ရပ်လိုက်ရင် (Cancel)
    // အလုပ်လုပ်တာကို ချက်ချင်း ရပ်ပစ်ဖို့ ဖြစ်ပါတယ်
    controller.onCancel = () async {
      await controller.close();
    };

    return controller.stream;
  }
}
