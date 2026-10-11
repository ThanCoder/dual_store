// // ignore_for_file: public_member_api_docs

// part of 'i_search.dart';

// class BinarySearch<T extends IDuModel> extends ISearch<T> {
//   new({required super.box, required super.event, required super.adapter});

//   @override
//   SearchType get type => .binary;

//   final SplayTreeMap<String, int> _treeMap = SplayTreeMap(
//     (key1, key2) => key1.compareTo(key2),
//   );
//   final Map<int, T> _map = {};

//   Future<void> _setCacheIfNotExists({int? parentId}) async {
//     _treeMap.clear();

//     if (_map.isEmpty) {
//       await for (var val in _box.streamAll(parentId: parentId)) {
//         _adapter.toMap(val).forEach((key, value) {
//           _treeMap['$key:$value-${val.generatedId}'] = val.generatedId;
//         });
//         _map[val.generatedId] = val;
//       }
//     }
//   }

//   @override
//   Future<List<T>> getAll({int? parentId}) async {
//     await _setCacheIfNotExists(parentId: parentId);
//     return _map.values.toList();
//   }

//   @override
//   Future<T?> findOne(bool Function(T value) test, {int? parentId}) async {
//     await _setCacheIfNotExists(parentId: parentId);
//     // SplayTreeMap ကို အသုံးပြု၍ test နှင့် ကိုက်ညီသည့် ပထမဆုံးအရာကို ရှာဖွေခြင်း
//     for (var key in _treeMap.keys) {
//       final id = _treeMap[key]!;
//       final val = _map[id];
//       if (val != null && test(val)) {
//         return val;
//       }
//     }
//     return null;
//   }

//   @override
//   Future<List<T>> find(bool Function(T value) test, {int? parentId}) async {
//     await _setCacheIfNotExists(parentId: parentId);
//     List<T> results = [];
//     // SplayTreeMap ၏ keys များကို စီစဉ်ထားသည့်အတိုင်း ဖြတ်သန်းရှာဖွေခြင်း
//     for (var key in _treeMap.keys) {
//       final id = _treeMap[key]!;
//       final val = _map[id];
//       if (val != null && test(val)) {
//         results.add(val);
//       }
//     }
//     return results;
//   }

//   @override
//   Future<T?> getOne({int? parentId}) async {
//     await _setCacheIfNotExists(parentId: parentId);
//     if (_map.isEmpty) return null;
//     return _map.values.first;
//   }
// }
