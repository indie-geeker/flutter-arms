import 'dart:io';

import 'package:args/args.dart';

// 转换为大驼峰 (CamelCase)
String toUpperCamelCase(String snakeCase) {
  return snakeCase.split('_').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join();
}

// 转换为小驼峰 (camelCase)
String toLowerCamelCase(String snakeCase) {
  final upper = toUpperCamelCase(snakeCase);
  if (upper.isEmpty) return upper;
  return upper[0].toLowerCase() + upper.substring(1);
}

void main(List<String> arguments) {
  final parser =
      ArgParser()
        ..addOption('name', abbr: 'n', help: 'Feature 名称 (例如: user_profile)');

  final argResults = parser.parse(arguments);
  final featureName = argResults['name'] as String?;

  if (featureName == null || featureName.isEmpty) {
    stderr.writeln('错误: 缺少 --name 参数。');
    stderr.writeln('用法: dart tool/gen_feature.dart --name <feature_name>');
    exit(1);
  }

  final className = toUpperCamelCase(featureName);
  final providerName = toLowerCamelCase(featureName);
  final libDir = Directory('lib/features/$featureName');

  if (libDir.existsSync()) {
    stderr.writeln('错误: Feature 目录已存在 (${libDir.path})。');
    exit(1);
  }

  stdout.writeln('🚀 正在生成 Feature: $featureName ($className)...');

  final filesToCreate = <String, String>{
    // --- Application Layer ---
    'application/${featureName}_usecases.dart': '''
import 'package:flutter_arms/features/$featureName/data/repositories/${featureName}_repository_impl.dart';
import 'package:flutter_arms/features/$featureName/domain/usecases/get_${featureName}_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${featureName}_usecases.g.dart';

/// $className 用例依赖注入。
@Riverpod(keepAlive: true)
Get${className}UseCase get${className}UseCase(Ref ref) {
  return Get${className}UseCase(ref.read(${providerName}RepositoryProvider));
}
''',

    // --- Data Layer ---
    'data/datasources/${featureName}_remote_datasource.dart': '''
import 'package:flutter_arms/features/$featureName/data/models/${featureName}_dto.dart';

/// $className 远程数据源接口。
abstract interface class ${className}RemoteDataSource {
  /// 获取 $className 数据。
  Future<${className}Dto> get();
}
''',
    'data/datasources/retrofit_${featureName}_remote_datasource.dart': '''
import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/features/$featureName/data/datasources/${featureName}_remote_datasource.dart';
import 'package:flutter_arms/features/$featureName/data/models/${featureName}_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'retrofit_${featureName}_remote_datasource.g.dart';

/// Retrofit $className API。
@RestApi()
abstract class Retrofit${className}Api {
  /// 构造函数。
  factory Retrofit${className}Api(Dio dio, {String baseUrl}) =
      _Retrofit${className}Api;

  /// 获取 $className 数据。
  @GET('/$featureName')
  Future<${className}Dto> get();
}

/// Retrofit $className 远程数据源。
final class Retrofit${className}RemoteDataSource
    implements ${className}RemoteDataSource {
  /// 构造函数。
  const Retrofit${className}RemoteDataSource(this._api);

  final Retrofit${className}Api _api;

  @override
  Future<${className}Dto> get() {
    return _api.get().asApi();
  }
}

/// 默认 $className 远程数据源：Retrofit 写法，适合快速 REST CRUD。
@Riverpod(keepAlive: true)
${className}RemoteDataSource ${providerName}RemoteDataSource(Ref ref) {
  return Retrofit${className}RemoteDataSource(
    Retrofit${className}Api(ref.read(dioProvider)),
  );
}
''',
    'data/datasources/api_client_${featureName}_remote_datasource.dart': '''
import 'package:flutter_arms/core/network/api_client.dart';
import 'package:flutter_arms/core/network/api_request.dart';
import 'package:flutter_arms/features/$featureName/data/datasources/${featureName}_remote_datasource.dart';
import 'package:flutter_arms/features/$featureName/data/models/${featureName}_dto.dart';

/// ApiClient $className 远程数据源：适合学习或长期替换网络库。
final class ApiClient${className}RemoteDataSource
    implements ${className}RemoteDataSource {
  /// 构造函数。
  const ApiClient${className}RemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<${className}Dto> get() {
    return _client.send(
      const ApiRequest<${className}Dto>.get('/$featureName', decode: _decodeDto),
    );
  }

  static ${className}Dto _decodeDto(Object? json) {
    return ${className}Dto.fromJson(json! as Map<String, dynamic>);
  }
}
''',
    'data/datasources/api_client_${featureName}_remote_datasource_provider.dart':
        '''
import 'package:flutter_arms/core/network/dio_api_client.dart';
import 'package:flutter_arms/features/$featureName/data/datasources/api_client_${featureName}_remote_datasource.dart';
import 'package:flutter_arms/features/$featureName/data/datasources/${featureName}_remote_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client_${featureName}_remote_datasource_provider.g.dart';

/// ApiClient $className 远程数据源依赖。
@Riverpod(keepAlive: true)
${className}RemoteDataSource ${providerName}ApiClientRemoteDataSource(Ref ref) {
  return ApiClient${className}RemoteDataSource(ref.read(apiClientProvider));
}
''',
    'data/models/${featureName}_dto.dart': '''
import 'package:flutter_arms/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${featureName}_dto.freezed.dart';
part '${featureName}_dto.g.dart';

/// $className DTO。
@freezed
abstract class ${className}Dto with _\$${className}Dto {
  /// 构造函数。
  const factory ${className}Dto({
    required String id,
  }) = _${className}Dto;

  /// JSON 反序列化。
  factory ${className}Dto.fromJson(Map<String, dynamic> json) =>
      _\$${className}DtoFromJson(json);
}

/// $className DTO 转换。
extension ${className}DtoMapper on ${className}Dto {
  /// 转换为实体。
  ${className}Entity toEntity() {
    return ${className}Entity(id: id);
  }
}
''',
    'data/repositories/${featureName}_repository_impl.dart': '''
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/$featureName/data/datasources/${featureName}_remote_datasource.dart';
import 'package:flutter_arms/features/$featureName/data/datasources/retrofit_${featureName}_remote_datasource.dart';
import 'package:flutter_arms/features/$featureName/data/models/${featureName}_dto.dart';
import 'package:flutter_arms/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:flutter_arms/features/$featureName/domain/repositories/${featureName}_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${featureName}_repository_impl.g.dart';

/// $className 仓储实现。
class ${className}RepositoryImpl implements ${className}Repository {
  /// 构造函数。
  const ${className}RepositoryImpl(this._remote);

  final ${className}RemoteDataSource _remote;

  @override
  Future<Result<${className}Entity>> getData() async {
    try {
      final dto = await _remote.get();
      return Result.success(dto.toEntity());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}

/// $className 仓储依赖注入。
@Riverpod(keepAlive: true)
${className}Repository ${providerName}Repository(Ref ref) {
  return ${className}RepositoryImpl(ref.read(${providerName}RemoteDataSourceProvider));
}
''',

    // --- Domain Layer ---
    'domain/entities/${featureName}_entity.dart': '''
/// $className 实体。
class ${className}Entity {
  /// 构造函数。
  const ${className}Entity({required this.id});

  /// ID。
  final String id;
}
''',
    'domain/repositories/${featureName}_repository.dart': '''
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/$featureName/domain/entities/${featureName}_entity.dart';

/// $className 仓储接口。
abstract interface class ${className}Repository {
  /// 获取 $className 数据。
  Future<Result<${className}Entity>> getData();
}
''',
    'domain/usecases/get_${featureName}_usecase.dart': '''
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/$featureName/domain/entities/${featureName}_entity.dart';
import 'package:flutter_arms/features/$featureName/domain/repositories/${featureName}_repository.dart';

/// 获取 $className 用例。
class Get${className}UseCase {
  /// 构造函数。
  const Get${className}UseCase(this._repository);

  final ${className}Repository _repository;

  /// 执行用例。
  Future<Result<${className}Entity>> call() {
    return _repository.getData();
  }
}
''',

    // --- Presentation Layer ---
    'presentation/pages/${featureName}_page.dart': '''
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// $className 页面。
@RoutePage()
class ${className}Page extends ConsumerWidget {
  /// 构造函数。
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('$className')),
      body: const Center(
        child: Text('$className Page'),
      ),
    );
  }
}
''',
    'presentation/states/${featureName}_state.dart': '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${featureName}_state.freezed.dart';

/// $className 页面状态。
@freezed
abstract class ${className}State with _\$${className}State {
  /// 构造函数。
  const factory ${className}State({
    @Default(false) bool isLoading,
  }) = _${className}State;
}
''',
    'presentation/view_models/${featureName}_notifier.dart': '''
import 'package:flutter_arms/features/$featureName/presentation/states/${featureName}_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${featureName}_notifier.g.dart';

/// $className 页面状态管理。
@riverpod
class ${className}Notifier extends _\$${className}Notifier {
  @override
  ${className}State build() {
    return const ${className}State();
  }
}
''',
    'presentation/widgets/.gitkeep': '',
  };

  for (final entry in filesToCreate.entries) {
    final filePath = 'lib/features/$featureName/${entry.key}';
    final file = File(filePath);
    file.parent.createSync(recursive: true);
    if (entry.value.isNotEmpty) {
      file.writeAsStringSync(entry.value);
    } else {
      file.createSync();
    }
  }

  stdout.writeln('✅ 生成完成: lib/features/$featureName');
  stdout.writeln('提示: 默认远程数据源使用 Retrofit；ApiClient 对照写法已一并生成。');
  stdout.writeln('提示: 请运行 `tool/gen.sh` 生成 `.g.dart` 和 `.freezed.dart` 代码。');
}
