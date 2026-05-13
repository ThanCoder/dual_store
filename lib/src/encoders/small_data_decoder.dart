import 'dart:typed_data';
import 'dart:convert';

/// Dual Small Data Decoder
class SmallDataDecoder {
  final Uint8List _data;
  int _cursor = 0; // လက်ရှိ ဖတ်နေတဲ့ နေရာကို မှတ်ထားတာ
  /// Dual Small Data Decoder
  SmallDataDecoder(this._data);

  // ၁။ Integer ပြန်ဖတ်မယ်
  int readInt() {
    // လက်ရှိ cursor နေရာကနေ 4 bytes ကို ယူမယ်
    var view = ByteData.view(_data.buffer, _data.offsetInBytes + _cursor, 4);
    _cursor += 4; // 4 bytes ဖတ်ပြီးသွားလို့ ရှေ့ကို ၄ နေရာ တိုးလိုက်တယ်
    return view.getInt32(0);
  }

  // ၂။ String ပြန်ဖတ်မယ်
  String readString() {
    // အရင်ဆုံး String ရဲ့ အရှည် (Length) ကို ဖတ်မယ် (အပေါ်က readInt ကို ပြန်သုံးတာ)
    int length = readInt();

    // ရလာတဲ့ length အတိုင်း bytes တွေကို ဖြတ်ထုတ်မယ်
    var stringBytes = _data.sublist(_cursor, _cursor + length);
    _cursor += length; // စာသားအရှည်အတိုင်း cursor ကို ရှေ့တိုးမယ်

    return utf8.decode(stringBytes);
  }

  // ၃။ Double ပြန်ဖတ်မယ်
  double readDouble() {
    var view = ByteData.view(_data.buffer, _data.offsetInBytes + _cursor, 8);
    _cursor += 8; // Double က 8 bytes ရှိတယ်
    return view.getFloat64(0);
  }

  // ၄။ Boolean ပြန်ဖတ်မယ်
  bool readBool() {
    int value = _data[_cursor];
    _cursor += 1; // Boolean က 1 byte ပဲ ရှိတယ်
    return value == 1;
  }
}
