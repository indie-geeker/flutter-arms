import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/src/base/i_api_client.dart';

class BaseApiClient {
  final IApiClient apiClient;
  final INetworkConfig config;

  BaseApiClient({
    required this.apiClient,
    required this.config,
  });

}