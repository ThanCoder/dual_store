abstract class IReader<T> {
  Future<T> readFromStream(Stream<List<int>> stream);
}
