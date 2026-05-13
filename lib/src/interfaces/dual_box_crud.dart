abstract class DualBoxCrud<T> {
  /// Delete All Record By AdapterTypeId
  Future<void> deleteAll();

  /// Delete By Id
  Future<void> deleteById(int id);

  /// Read Big Data From Database
  Future<Stream<List<int>>?> readBigData(T value);

  /// Read Big Data From Database
  ///
  /// String အဖြစ် ပြန်ယူမယ်
  Future<String?> readBigDataAsString(T value);

  /// Read Big Data From Database
  ///
  /// JSON အဖြစ် ပြန်ယူမယ်
  Future<dynamic> readBigDataAsJson(T value);

  /// ### Add Data
  ///
  /// [bigDataStream] Custom Data
  ///
  ///If You Used BigDataStram.
  ///
  ///You Should Use
  ///
  ///```dart
  /// addWithBigDataString();
  /// addWithBigDataMap();
  /// addWithBigDataFile();
  ///```
  /// For Safe Method.
  ///
  Future<void> add(
    T value, {
    Stream<List<int>>? bigDataStream,
    int? bigDataSize,
    void Function(double progerss)? onProgress,
  });

  /// ### Add Data With Big Data Map
  ///
  /// [bigMap] Custom Data
  ///
  Future<void> addWithBigDataMap(
    T value, {
    required Map<String, dynamic> bigMap,
    void Function(double progerss)? onProgress,
  });

  /// ### Add Data With Big String
  ///
  /// [bigString] Custom Data
  ///
  Future<void> addWithBigDataString(
    T value, {
    required String bigString,
    void Function(double progerss)? onProgress,
  });

  /// ### Add Data With File
  ///
  /// [filePath] Custom Data
  ///
  Future<void> addWithBigDataFile(
    T value, {
    required String filePath,
    void Function(double progerss)? onProgress,
  });

  ///
  /// ### Get All `List<T>`
  ///
  Future<List<T>> getAll({int? parentId});
}
