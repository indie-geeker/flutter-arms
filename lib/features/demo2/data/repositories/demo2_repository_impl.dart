import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/demo2/domain/repositories/demo2_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'demo2_repository_impl.g.dart';

class Demo2RepositoryImpl implements Demo2Repository {
  // const Demo2RepositoryImpl(this._remote);
  // final Demo2RemoteDataSource _remote;
}

@Riverpod(keepAlive: true)
Demo2Repository demo2Repository(Ref ref) {
  return Demo2RepositoryImpl();
}
