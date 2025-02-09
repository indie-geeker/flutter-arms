import 'package:equatable/equatable.dart';

/// 所有Failure的基类
abstract class Failure extends Equatable {
  final String? message;
  
  const Failure([this.message]);

  @override
  List<Object?> get props => [message];
}

/// 服务器错误
class ServerFailure extends Failure {
  const ServerFailure([String? message]) : super(message);
}

/// 缓存错误
class CacheFailure extends Failure {
  const CacheFailure([String? message]) : super(message);
}

/// 网络错误
class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) : super(message);
}

/// 验证错误
class ValidationFailure extends Failure {
  const ValidationFailure([String? message]) : super(message);
}

/// 未授权错误
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String? message]) : super(message);
}

/// 未知错误
class UnknownFailure extends Failure {
  const UnknownFailure([String? message]) : super(message);
}