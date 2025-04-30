import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;


  /// 这里添加API方法
  /// 返回类型统一为 HttpResponse
  /// 因为API客户端层为基础设施层，不应该了解业务模型
  /// 由数据源层负责将JSON转换为领域模型
  /// 这里没有直接返回 Map<String,dynamic>，是因为生成类中的 fromJson必须指定类型

  // 示例:

  // @POST("/user/register")
  // Future<Map<String,dynamic>> register(String username, String password);

  @POST("/user/login")
  Future<HttpResponse> login(String username, String password);

  // @RawResponseResult()
  // @GET("/user/info")
  // Future<Map<String,dynamic>> getUserInfo();

  @GET("/user/logout")
  Future<HttpResponse> logout();
}
