
import 'package:app_interfaces/app_interfaces.dart';


class AdaptableResponseConverter implements IAdaptableResponseConvert {
  final IResponseAdapter adapter;

  const AdaptableResponseConverter(this.adapter);


  @override
  Result<T> convert<T>(dynamic response, T Function(dynamic) fromJson) {
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
        message: e.toString(),
      ));
    }
  }
}