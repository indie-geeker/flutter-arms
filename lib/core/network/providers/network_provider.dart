import 'package:flutter_arms/app/config/config_manager.dart';
import 'package:flutter_arms/core/network/api_client_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../adapters/default_response_adapter.dart';
import '../adapters/response_adapter.dart';
import '../api_client.dart';

part 'network_provider.g.dart';

/// API客户端包装类，保留adapter引用
class ApiClientWrapper {
  final ApiClient client;
  final ResponseAdapter adapter;

  const ApiClientWrapper(this.client, this.adapter);
}


@riverpod
ApiClientWrapper apiClientWithAdapter(Ref ref, {ResponseAdapter? adapter}) {
  final actualAdapter = adapter ?? ref.watch(defaultResponseAdapterProvider);
  
  final client = ApiClientFactory.createDefaultApiClient(
      ConfigManager().getEnvConfig().apiBaseUrl,
      adapter: actualAdapter!);
      
  return ApiClientWrapper(client, actualAdapter);
}

/// API客户端提供者
/// 
/// 可以通过参数传入自定义的ResponseAdapter
/// 如果不传入，则使用defaultResponseAdapterProvider提供的适配器
@riverpod
ApiClient apiClient(Ref ref, {ResponseAdapter? adapter}) {
  // 使用提供的adapter或默认的adapter
  final actualAdapter = adapter ?? ref.watch(defaultResponseAdapterProvider);
  
  return ApiClientFactory.createDefaultApiClient(
      ConfigManager().getEnvConfig().apiBaseUrl,
      adapter: actualAdapter!);
}

/// 默认的API客户端
/// 使用默认响应适配器
final defaultApiClientProvider = Provider((ref) {
  return ref.watch(apiClientProvider());
});

/// 提供默认的响应适配器
@riverpod
ResponseAdapter defaultResponseAdapter(Ref ref) {
  return const DefaultResponseAdapter();
}
