// Using extension type with possible null parameters could fail because of
// https://github.com/dart-lang/language/issues/4314
final class ResultType<T> {
  const ResultType(this.data);

  final T data;
}