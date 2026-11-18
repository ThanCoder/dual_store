// ignore_for_file: public_member_api_docs

sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() {
    return switch (this) {
      Ok(value: final val) => val,
      Err() => throw StateError('Called `unwrap()` on Err'),
    };
  }

  E unwrapError() {
    return switch (this) {
      Err(err: final val) => val,
      Ok() => throw StateError('Called `unwrapError()` on Ok'),
    };
  }

  R fold<R>({
    required R Function(E err) onErr,
    required R Function(T val) onOk,
  }) => switch (this) {
    Ok(value: final val) => onOk(val),
    Err(err: final val) => onErr(val),
  };

  void onResult({
    required void Function(E err) onErr,
    required void Function(T val) onOk,
  }) => switch (this) {
    Ok(value: final val) => onOk(val),
    Err(err: final val) => onErr(val),
  };

  void onErr({required void Function(E err) onErr}) => switch (this) {
    Ok() => {},
    Err(err: final val) => onErr(val),
  };

  void onOk({required void Function(T val) onOk}) => switch (this) {
    Ok(value: final val) => onOk(val),
    Err() => {},
  };
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E err;
  const Err(this.err);
}
