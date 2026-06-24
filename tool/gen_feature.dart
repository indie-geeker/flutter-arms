import 'dart:io';

import 'package:args/args.dart';

// 转换为大驼峰 (CamelCase)
String toUpperCamelCase(String snakeCase) {
  return snakeCase.split('_').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join('');
}

// 转换为小驼峰 (camelCase)
String toLowerCamelCase(String snakeCase) {
  final upper = toUpperCamelCase(snakeCase);
  if (upper.isEmpty) return upper;
  return upper[0].toLowerCase() + upper.substring(1);
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', help: 'Feature 名称 (例如: user_profile)');

  final argResults = parser.parse(arguments);
  final featureName = argResults['name'] as String?;

  if (featureName == null || featureName.isEmpty) {
    print('错误: 缺少 --name 参数。');
    print('用法: dart tool/gen_feature.dart --name <feature_name>');
    exit(1);
  }

  final className = toUpperCamelCase(featureName);
  final libDir = Directory('lib/features/$featureName');

  if (libDir.existsSync()) {
    print('错误: Feature 目录已存在 (${libDir.path})。');
    exit(1);
  }

  print('🚀 正在生成 Feature: $featureName ($className)...');

  // 定义目录结构和空文件
  final filesToCreate = {
    // --- Data Layer ---
    'data/datasources/${featureName}_remote_datasource.dart': '''
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part '${featureName}_remote_datasource.g.dart';

@RestApi()
abstract class ${className}RemoteDataSource {
  factory ${className}RemoteDataSource(Dio dio) = _${className}RemoteDataSource;

  // @GET('/api/v1/$featureName')
  // Future<dynamic> get();
}
''',
    'data/models/${featureName}_dto.dart': '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${featureName}_dto.freezed.dart';
part '${featureName}_dto.g.dart';

@freezed
class ${className}Dto with _\$${className}Dto {
  const factory ${className}Dto({
    required String id,
  }) = _${className}Dto;

  factory ${className}Dto.fromJson(Map<String, dynamic> json) => _\$${className}DtoFromJson(json);
}
''',
    'data/repositories/${featureName}_repository_impl.dart': '''
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/$featureName/domain/repositories/${featureName}_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${featureName}_repository_impl.g.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  // const ${className}RepositoryImpl(this._remote);
  // final ${className}RemoteDataSource _remote;
}

@Riverpod(keepAlive: true)
${className}Repository ${toLowerCamelCase(featureName)}Repository(Ref ref) {
  return ${className}RepositoryImpl();
}
''',

    // --- Domain Layer ---
    'domain/entities/${featureName}_entity.dart': '''
class ${className}Entity {
  const ${className}Entity({required this.id});
  final String id;
}
''',
    'domain/repositories/${featureName}_repository.dart': '''
abstract class ${className}Repository {
  // Future<Result<${className}Entity>> getData();
}
''',
    'domain/usecases/get_${featureName}_usecase.dart': '''
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/$featureName/domain/repositories/${featureName}_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_${featureName}_usecase.g.dart';

class Get${className}UseCase {
  const Get${className}UseCase(this._repository);
  final ${className}Repository _repository;

  // Future<Result<dynamic>> call() => _repository.getData();
}

@Riverpod(keepAlive: true)
Get${className}UseCase get${className}UseCase(Ref ref) {
  return Get${className}UseCase(ref.read(${toLowerCamelCase(featureName)}RepositoryProvider));
}
''',

    // --- Presentation Layer ---
    'presentation/pages/${featureName}_page.dart': '''
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ${className}Page extends ConsumerWidget {
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

@freezed
class ${className}State with _\$${className}State {
  const factory ${className}State({
    @Default(false) bool isLoading,
  }) = _${className}State;
}
''',
    'presentation/view_models/${featureName}_notifier.dart': '''
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_arms/features/$featureName/presentation/states/${featureName}_state.dart';

part '${featureName}_notifier.g.dart';

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

  print('✅ 生成完成: lib/features/$featureName');
  print('提示: 请运行 `tool/gen.sh` 来生成 `.g.dart` 和 `.freezed.dart` 代码！');
}
