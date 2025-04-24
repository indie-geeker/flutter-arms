import 'package:equatable/equatable.dart';

/// 所有Failure的基类
/// 对应于异常的失败类型
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic details;

  const Failure({required this.message, this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];
}

/// 缓存错误
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 网络错误
class NetworkFailure extends Failure {
  final int? statusCode;

  const NetworkFailure(
      {required super.message, super.code, super.details, this.statusCode});
}

/// 未授权错误
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 服务器错误
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 解析错误
class ParseFailure extends Failure {
  const ParseFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 未知错误
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });
}
