import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // 这里添加API方法
  // 示例:
  // @GET("/users/{id}")
  // Future<Response> getUser(@Path("id") String id);
}
