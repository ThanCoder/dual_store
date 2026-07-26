import 'package:dual_store/src/interfaces/i_meta.dart';
import 'package:dual_store/src/interfaces/i_writer.dart';

typedef OnWriterProgerssCallback = void Function(double progress);

// ၁။ Meta Data တွေကို ရှာဖွေပေးဖို့ပဲ တာဝန်ရှိတဲ့ အပိုင်း
abstract class IMetaRepository {
  Future<List<IMeta>> getAllMetas();
}

// ၂။ File သို့မဟုတ် ဒေတာထဲကနေ Data တွေကို ဖတ်ပေးဖို့ပဲ တာဝန်ရှိတဲ့ အပိုင်း
abstract class IDataReader {
  Stream<List<int>> readData(IMeta meta);
}

// ၃။ Data တွေကို ရေးသားပေးဖို့ပဲ တာဝန်ရှိတဲ့ အပိုင်း
abstract class IDataWriter {
  Future<void> write(
    IRecordWriter writer, {
    OnWriterProgerssCallback? onProgress,
  });
}

// ၄။ ဖွင့်ထားတဲ့ ဖိုင် သို့မဟုတ် Resource တွေကို သန့်ရှင်းရေးလုပ် ပိတ်ပေးဖို့ပဲ တာဝန်ရှိတဲ့ အပိုင်း
abstract class IResourceLifecycle {
  Future<void> close();
}

// Interface ၄ ခုလုံးကို စုစည်းထားတဲ့ Master Interface အဖြစ် ပြောင်းလဲသတ်မှတ်ခြင်း
abstract class IEngine
    implements IMetaRepository, IDataReader, IDataWriter, IResourceLifecycle {}
