import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'demo2_remote_datasource.g.dart';

@RestApi()
abstract class Demo2RemoteDataSource {
  factory Demo2RemoteDataSource(Dio dio) = _Demo2RemoteDataSource;

  // @GET('/api/v1/demo2')
  // Future<dynamic> get();
}
