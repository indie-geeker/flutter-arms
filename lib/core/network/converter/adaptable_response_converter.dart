import 'package:dio/dio.dart';
import '../../errors/result.dart';
import '../../errors/failures.dart';
import '../adapters/response_adapter.dart';

class AdaptableResponseConverter {
  final ResponseAdapter adapter;

  const AdaptableResponseConverter(this.adapter);

  Result<T> convert<T>(Response response, T Function(dynamic) fromJson) {
    try {
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;

        if (!adapter.isSuccess(map)) {
          return Result.failure(ServerFailure(
            message: adapter.getMessage(map),
            code: adapter.getStatusCode(map) is int
                ? adapter.getStatusCode(map)
                : null,
          ));
        }

        final data = adapter.getData(map);
        if (data == null) {
          return Result.success(null as T);
        }

        return Result.success(fromJson(data));
      }

      return Result.success(fromJson(response.data));
    } on Exception catch (e) {
      return Result.failure(ParseFailure(
        message: '解析错误: ${e.toString()}',
      ));
    }
  }
}