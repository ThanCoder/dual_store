// ignore_for_file: public_member_api_docs
part of 'i_search.dart';

class SearchEventState<T> {
  const SearchEventState({
    required this.all,
    required this.error,
    required this.add,
    required this.update,
    required this.delete,
  });

  final Stream<SearchEvent> all;
  final Stream<Error> error;
  final Stream<Add<T>> add;
  final Stream<Update<T>> update;
  final Stream<Delete<T>> delete;
}

extension SearchEventX on Stream<SearchEvent> {
  Stream<T> whereType<T>() {
    return where((e) => e is T) as Stream<T>;
  }
}
