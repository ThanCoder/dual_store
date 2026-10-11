// ignore_for_file: public_member_api_docs

part of 'i_search.dart';

sealed class SearchEvent {
  const new();
}

class Add<T> extends SearchEvent {
  final T value;
  new(this.value);
}

class Update<T> extends SearchEvent {
  final T value;
  new(this.value);
}

class Delete<T> extends SearchEvent {
  final T value;
  new(this.value);
}

class Error extends SearchEvent {
  final String message;
  const new(this.message);
}
