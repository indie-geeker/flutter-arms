import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/features/%feature%/data/models/%feature%_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_remote_datasource.g.dart';

/// %Feature% 远程数据源。
@RestApi()
abstract class %Feature%RemoteDataSource {
  /// 构造函数。
  factory %Feature%RemoteDataSource(Dio dio, {String baseUrl}) =
      _%Feature%RemoteDataSource;

  // TODO(%feature%): 替换为真实端点。下面三个是常见形状，按需保留/删除。

  /// 获取列表。
  @GET('/%feature%')
  Future<List<%Feature%Dto>> list();

  /// 获取详情。
  @GET('/%feature%/{id}')
  Future<%Feature%Dto> detail(@Path('id') String id);

  /// 创建。
  @POST('/%feature%')
  Future<%Feature%Dto> create(@Body() Map<String, dynamic> body);
}

/// %Feature% 远程数据源依赖注入。
@Riverpod(keepAlive: true)
%Feature%RemoteDataSource %feature%RemoteDataSource(Ref ref) {
  return %Feature%RemoteDataSource(ref.read(dioProvider));
}
