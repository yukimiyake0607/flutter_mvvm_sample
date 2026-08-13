/// ViewModelでswitchしてRepositoryの結果を分岐するために使用。
///
/// Repositoryの戻りをthrowではなく、成功なら値、失敗ならExceptionのオブジェクトにします。
/// 失敗は例外ではなく[Result]として返す。
sealed class Result<T> {
  const Result();

  /// valueを含む正常な[Result]を作成します。
  factory Result.ok(T value) => Ok(value);

  /// errorを含む異常な[Result]を作成します。
  factory Result.error(Exception error) => Error(error);
}

/// 成功した時に使用するResultのサブクラス
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  // 成功した際に渡す値
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// 失敗した時に使用するResultのサブクラス
final class Error<T> extends Result<T> {
  const Error(this.error);

  // 失敗した時に返す例外
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
