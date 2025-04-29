import 'package:flutter_arms/app/config/config_manager.dart';
import 'package:flutter_arms/core/network/api_client_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';
part 'network_provider.g.dart';

@riverpod
ApiClient defaultApiClient (Ref ref) {
  return ApiClientFactory.createDefaultApiClient(ConfigManager().getEnvConfig().apiBaseUrl);
}
