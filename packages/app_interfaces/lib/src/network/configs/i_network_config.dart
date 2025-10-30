
import '../../../app_interfaces.dart';
import 'cache_policy_config.dart';

abstract class INetWorkConfig{
  String get baseUrl;
  Duration get receiveTimeout;
  Duration get connectTimeout;

  RetryConfig get retryConfig => const RetryConfig();

  CachePolicyConfig get cachePolicyConfig => const CachePolicyConfig();



}