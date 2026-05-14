typedef FindFuncCallback<T> = bool Function(T value);

abstract class DualBoxCrud<T> {
  /// ### Get One
  Future<T?> getOne(FindFuncCallback<T> test, {int? parentId});

  /// ### Find Query
  Future<List<T>> find(FindFuncCallback<T> test, {int? parentId});

  /// ### Get One Stream
  Stream<T?> getOneStream(FindFuncCallback<T> test, {int? parentId});

  /// ### Find Query
  Stream<List<T>> findStream(FindFuncCallback<T> test, {int? parentId});

  ///
  /// ### Get All `List<T>`
  ///
  Future<List<T>> getAll({int? parentId});

  ///
  /// ### Get All `List<T>`
  ///
  Stream<T> getAllStream({int? parentId});

  /// Delete All Record By AdapterTypeId
  Future<void> deleteAll();

  /// Delete By Id
  ///
  /// Return -> if deleted ? true : false
  Future<bool> deleteById(int id);

  ///
  /// Delete By Id With List
  ///
  Future<void> deleteByIdList(List<int> ids);

  /// Update By Id
  ///
  /// Return -> if updated ? true : false
  ///
  Future<bool> updateById(int id, T value);

  /// Update By Id With Big String
  ///
  /// Return -> if updated ? true : false
  ///
  Future<bool> updateByIdWithBigString(
    int id,
    T value, {
    required String bigString,
  });

  /// Update By Id With Big Map
  ///
  /// Return -> if updated ? true : false
  ///
  Future<bool> updateByIdWithBigMap(
    int id,
    T value, {
    required Map<String, dynamic> bigMap,
  });

  /// Update By Id With Big Data
  ///
  /// Return -> if updated ? true : false
  ///
  Future<bool> updateByIdWithBigData(
    int id,
    T value, {
    Stream<List<int>>? bigDataStream,
    int? bigDataSize,
    void Function(double progerss)? onProgress,
  });

  /// Read Big Data From Database
  Future<Stream<List<int>>?> readBigData(T value);

  /// Read Big Data From Database
  ///
  /// String အဖြစ် ပြန်ယူမယ်
  Future<String?> readBigDataAsString(T value);

  /// Read Big Data From Database
  ///
  /// Return -> As Map
  Future<Map<String, dynamic>?> readBigDataAsMap(
    T value, {
    void Function(String error)? onError,
  });

  /// ### Add Data With BigData
  ///
  /// Return -> `[generated id]`
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

  Future<int> addWithBigData(
    T value, {
    Stream<List<int>>? bigDataStream,
    int? bigDataSize,
    void Function(double progerss)? onProgress,
  });

  ///
  /// ### Add Small Data Without BigStream Data
  ///
  /// Return -> `[generated id]`
  ///
  Future<int> add(T value);

  /// ### Add Data With Big Data Map
  ///
  /// Return -> `[generated id]`
  ///
  /// [bigMap] Custom Data
  ///
  Future<int> addWithBigDataMap(
    T value, {
    required Map<String, dynamic> bigMap,
  });

  /// ### Add Data With Big String
  ///
  /// Return -> `[generated id]`
  ///
  /// [bigString] Custom Data
  ///
  Future<int> addWithBigDataString(T value, {required String bigString});

  /// ### Add Data With File
  ///
  /// Return -> `[generated id]`
  ///
  /// [filePath] Custom Data
  ///
  Future<int> addWithBigDataFile(
    T value, {
    required String filePath,
    void Function(double progerss)? onProgress,
  });
}
