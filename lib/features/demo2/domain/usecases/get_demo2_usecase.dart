import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/demo2/domain/repositories/demo2_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_demo2_usecase.g.dart';

class GetDemo2UseCase {
  const GetDemo2UseCase(this._repository);
  final Demo2Repository _repository;

  // Future<Result<dynamic>> call() => _repository.getData();
}

@Riverpod(keepAlive: true)
GetDemo2UseCase getDemo2UseCase(Ref ref) {
  return GetDemo2UseCase(ref.read(demo2RepositoryProvider));
}
