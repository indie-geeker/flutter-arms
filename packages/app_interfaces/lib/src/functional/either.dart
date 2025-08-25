/// 表示可能是左值或右值的类型
/// Left 通常用于表示失败的情况（如 Failure）
/// Right 通常用于表示成功的情况（如 Success）
abstract class Either<L, R> {
  const Either();

  /// 根据Either的类型执行不同的函数
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);

  /// 判断是否为Left
  bool isLeft();

  /// 判断是否为Right
  bool isRight();

  /// 获取Left值，如果是Right则返回null
  L? getLeftOrNull();

  /// 获取Right值，如果是Left则返回null
  R? getRightOrNull();
}

/// 左值
class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) => leftFn(value);

  @override
  bool isLeft() => true;

  @override
  bool isRight() => false;

  @override
  L? getLeftOrNull() => value;

  @override
  R? getRightOrNull() => null;
}

/// 右值
class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) => rightFn(value);

  @override
  bool isLeft() => false;

  @override
  bool isRight() => true;

  @override
  L? getLeftOrNull() => null;

  @override
  R? getRightOrNull() => value;
}