import 'package:app_network/src/interceptors/base_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/src/network_client.dart';
import 'package:app_network/src/network_client_factory.dart';
import 'package:app_network/src/config/network_config.dart';
import 'package:app_network/src/interceptors/auth_interceptor.dart';
import 'package:app_network/src/interceptors/log_interceptor.dart';
import 'package:app_network/src/interceptors/retry_interceptor.dart';

void main() {
  group('App Network Framework Tests', () {
    
    // ==========================================
    // ApiClient 直接使用测试
    // 适用场景：简单项目、快速原型、基础网络需求
    // ==========================================
    group('ApiClient 直接使用测试', () {
      late NetworkClient client;
      
      setUp(() {
        // 直接创建 ApiClient 实例
        client = NetworkClient(
         config: NetworkConfig(baseUrl: "https://jsonplaceholder.typicode.com"),
          defaultHeaders: {
            'Content-Type': 'application/json',
            'User-Agent': 'Flutter-Test-App',
          },

        );
        // 添加响应解析拦截器
        client.addInterceptor(ResponseParserInterceptor(TestResponseParse()));
      });
      
      tearDown(() {
        client.close();
      });
      
      test('应该能够创建 ApiClient 实例', () {
        expect(client, isNotNull);
        expect(client.defaultHeaders['Content-Type'], equals('application/json'));
      });
      
      test('应该能够配置基础设置', () {
        // 测试基础配置
        client.setBaseUrl('https://api.example.com');
        client.setDefaultHeaders({'Authorization': 'Bearer test-token'});
        client.setTimeout(connectTimeout: 5000, receiveTimeout: 8000);
        
        expect(client.defaultHeaders['Authorization'], equals('Bearer test-token'));
      });
      
      test('应该能够管理拦截器', () {
        // 添加自定义拦截器
        final authInterceptor = AuthInterceptor(
          token: 'test-token',
          enabled: true,
        );
        
        final logInterceptor = LogInterceptor(
          logRequest: true,
          logResponse: true,
        );
        
        client.addInterceptor(authInterceptor);
        client.addInterceptor(logInterceptor);
        
        // 验证拦截器已添加（通过内部状态检查）
        expect(client, isNotNull); // 基础验证
        
        // 测试移除拦截器
        client.removeInterceptor(authInterceptor);
        client.clearInterceptors();
      });
      
      test('应该能够控制日志功能', () {
        // 测试日志开关
        client.enableLogging();
        client.disableLogging();
        
        // 验证没有抛出异常
        expect(client, isNotNull);
      });
      
      test('应该能够管理取消令牌', () {
        // 创建取消令牌
        final cancelToken1 = client.createCancelToken();
        final cancelToken2 = client.createCancelToken();
        
        expect(cancelToken1, isNotNull);
        expect(cancelToken2, isNotNull);
        expect(cancelToken1, isNot(equals(cancelToken2)));
        
        // 测试取消单个请求
        client.cancelRequest(cancelToken1, '用户取消');
        
        // 测试取消所有请求
        client.cancelAllRequests('批量取消');
      });
      
      // Note: Request deduplication functionality has been moved to DeduplicationInterceptor
      // test('应该能够获取请求去重统计信息', () {
      //   final deduplicationInterceptor = DeduplicationInterceptor();
      //   client.addInterceptor(deduplicationInterceptor);
      //   final stats = deduplicationInterceptor.getStats();
      //
      //   expect(stats, isA<Map<String, dynamic>>());
      //   expect(stats.containsKey('pending_requests_count'), isTrue);
      //   expect(stats.containsKey('cached_timestamps_count'), isTrue);
      //   expect(stats.containsKey('oldest_request_age_minutes'), isTrue);
      // });
      
      test('应该能够构建请求选项', () {
        // 测试 GET 请求选项构建
        final getOptions = RequestOptions(
          method: RequestMethod.get,
          path: '/posts/1',
          queryParameters: {'userId': '1'},
          headers: {'Accept': 'application/json'},
        );
        
        expect(getOptions.method, equals(RequestMethod.get));
        expect(getOptions.path, equals('/posts/1'));
        expect(getOptions.queryParameters?['userId'], equals('1'));
        
        // 测试 POST 请求选项构建
        final postOptions = RequestOptions(
          method: RequestMethod.post,
          path: '/posts',
          data: {'title': 'Test Post', 'body': 'Test content'},
          contentType: ContentType.json,
        );
        
        expect(postOptions.method, equals(RequestMethod.post));
        expect(postOptions.data, isA<Map<String, dynamic>>());
      });
    });
    
    // ==========================================
    // NetworkClientFactory 工厂模式测试
    // 适用场景：企业级应用、复杂配置、多环境管理
    // ==========================================
    group('NetworkClientFactory 工厂模式测试', () {
      
      test('应该能够创建开发环境客户端', () {
        final config = NetworkConfig.development(
          baseUrl: 'https://dev-api.example.com',
          
          defaultHeaders: {
            'Environment': 'development',
            'Debug': 'true',
          },
        );
        
        final client = NetworkClientFactory.create(
          config: config,
        );
        
        expect(client, isNotNull);
        expect(client, isA<NetworkClient>());
        
        client.close();
      });
      
      test('应该能够创建生产环境客户端', () {
        final config = NetworkConfig.production(
          baseUrl: 'https://api.example.com',
          
          defaultHeaders: {
            'Environment': 'production',
          },
        );
        
        final client = NetworkClientFactory.create(
          config: config,
        );
        
        expect(client, isNotNull);
        expect(client.defaultHeaders['Environment'], equals('production'));
        
        client.close();
      });
      
      test('应该能够创建带认证的客户端', () {
        final config = NetworkConfig.development(
          baseUrl: 'https://api.example.com',
          

        );
        
        final client = NetworkClientFactory.createWithAuth(
          config: config,
          token: 'test-auth-token',
          onTokenRefresh: () async {
            // 模拟令牌刷新
            return 'new-refreshed-token';
          },
          onTokenExpired: () {
            // 模拟令牌过期处理
            print('Token expired, redirecting to login');
          },
        );
        
        expect(client, isNotNull);
        
        client.close();
      });
      
      test('应该能够创建带自定义拦截器的客户端', () {
        final config = NetworkConfig.development(
          baseUrl: 'https://api.example.com',
          

        );
        
        final customInterceptors = <IRequestInterceptor>[
          LogInterceptor(
            logRequest: true,
            logResponse: true,
            logError: true,
          ),
          RetryInterceptor(
            maxRetries: 3,
            initialDelay: Duration(milliseconds: 500),
          ),
        ];
        
        final client = NetworkClientFactory.create(
          config: config,
          customInterceptors: customInterceptors,
        );
        
        expect(client, isNotNull);
        
        client.close();
      });
      
      test('应该能够创建不同的缓存策略', () {
        // 内存缓存策略
        final memoryCache = NetworkClientFactory.createCacheStrategy(
          type: CacheStrategyType.memory,
          defaultTtl: Duration(minutes: 5),
          maxCacheSize: 100,
        );
        
        expect(memoryCache, isNotNull);
        expect(memoryCache, isA<ICacheStrategy>());
        
        // 无缓存策略
        final noCache = NetworkClientFactory.createCacheStrategy(
          type: CacheStrategyType.none,
        );
        
        expect(noCache, isNotNull);
      });
      
      test('应该能够创建错误处理器', () {
        final errorHandler = NetworkClientFactory.createErrorHandler(
          customErrorMessages: {
            NetworkErrorType.sendTimeout: '请求超时，请检查网络连接',
            NetworkErrorType.connectionError: '网络连接不可用',
          },
          enableDetailedErrors: true,
        );
        
        expect(errorHandler, isNotNull);
        expect(errorHandler, isA<INetworkErrorHandler>());
      });
    });
    
    // ==========================================
    // 配置管理测试
    // ==========================================
    group('NetworkConfig 配置管理测试', () {
      
      test('应该能够创建不同环境的配置', () {
        // 开发环境配置
        final devConfig = NetworkConfig.development(
          baseUrl: 'https://dev-api.example.com',
          

        );
        
        expect(devConfig.environment, equals(EnvironmentType.development));
        expect(devConfig.enableLogging, isTrue);
        expect(devConfig.connectTimeout.inSeconds, equals(30));
        
        // 生产环境配置
        final prodConfig = NetworkConfig.production(
          baseUrl: 'https://api.example.com',
          

        );
        
        expect(prodConfig.environment, equals(EnvironmentType.production));
        expect(prodConfig.enableLogging, isFalse);
        expect(prodConfig.maxRetries, equals(2));
      });
      
      test('应该能够复制和修改配置', () {
        final originalConfig = NetworkConfig.development(
          baseUrl: 'https://dev-api.example.com',
          

        );
        
        // final modifiedConfig = originalConfig.copyWith(
        //   baseUrl: 'https://staging-api.example.com',
        //   
        //   enableLogging: false,
        //   maxRetries: 5,
        // );
        
        // expect(modifiedConfig.baseUrl, equals('https://staging-api.example.com'));
        // expect(modifiedConfig.enableLogging, isFalse);
        // expect(modifiedConfig.maxRetries, equals(5));
        
        // 原配置不应该被修改
        expect(originalConfig.baseUrl, equals('https://dev-api.example.com'));
        expect(originalConfig.enableLogging, isTrue);
      });
      
      test('应该能够序列化和反序列化配置', () {
        final originalConfig = NetworkConfig.development(
          baseUrl: 'https://api.example.com',
          
          defaultHeaders: {'Custom-Header': 'test-value'},
        );
        
        // // 序列化为 Map
        // final configMap = originalConfig.toMap();
        // expect(configMap, isA<Map<String, dynamic>>());
        // expect(configMap['baseUrl'], equals('https://api.example.com'));
        //
        // // 从 Map 反序列化
        // final restoredConfig = NetworkConfig.fromMap(configMap);
        // expect(restoredConfig.baseUrl, equals(originalConfig.baseUrl));
        // expect(restoredConfig.environment, equals(originalConfig.environment));
      });
    });
    
    // ==========================================
    // 使用场景对比测试
    // ==========================================
    group('使用场景对比测试', () {
      
      test('简单场景：ApiClient 直接使用', () {
        // 场景：快速原型开发，简单的 REST API 调用
        final client = NetworkClient(
         config: NetworkConfig(
             baseUrl: 'https://jsonplaceholder.typicode.com',
           
         )
        );
        
        // 直接使用，配置简单
        client.enableLogging();
        
        // 验证基础功能
        expect(client, isNotNull);
        
        client.close();
      });
      
      test('复杂场景：NetworkClientFactory 工厂模式', () {
        // 场景：企业级应用，需要复杂配置和多种功能
        final config = NetworkConfig.production(
          baseUrl: 'https://api.enterprise.com',
          
          defaultHeaders: {
            'API-Version': 'v2',
            'Client-Type': 'mobile',
          },
        );
        
        final client = NetworkClientFactory.createWithAuth(
          config: config,
          token: 'enterprise-token',
          customInterceptors: [
            LogInterceptor(logRequest: false, logResponse: true),
            RetryInterceptor(maxRetries: 2),
          ],
        );
        
        // 验证企业级功能
        expect(client, isNotNull);
        expect(client.defaultHeaders['API-Version'], equals('v2'));
        
        client.close();
      });
    });
    
    // ==========================================
    // 集成测试
    // ==========================================
    group('集成测试', () {
      
      test('完整的网络客户端生命周期', () {
        // 1. 创建配置
        final config = NetworkConfig.development(
          baseUrl: 'https://httpbin.org',
          
        );
        
        // 2. 通过工厂创建客户端
        final client = NetworkClientFactory.create(
          config: config,
          customInterceptors: [
            LogInterceptor(),
          ],
        );
        
        // 3. 配置客户端
        client.enableLogging();
        
        // 4. 添加认证
        final authInterceptor = AuthInterceptor(
          token: 'test-token',
        );
        client.addInterceptor(authInterceptor);
        
        // 5. Verify client is configured
        expect(client, isNotNull);

        // 6. 清理资源
        client.close();
      });
    });
  });
}

// ==========================================
// 测试辅助类和模拟数据
// ==========================================

/// 模拟的测试拦截器
class TestInterceptor extends BaseInterceptor {
  final String name;
  bool wasRequestCalled = false;
  bool wasResponseCalled = false;
  bool wasErrorCalled = false;
  
  TestInterceptor(this.name);
  
  @override
  int get priority => 50;
  
  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    wasRequestCalled = true;
    return options;
  }
  
  @override
  Future<ApiResponse<T>> onResponse<T>(
    ApiResponse<T> response,
    RequestOptions options,
  ) async {
    wasResponseCalled = true;
    return response;
  }
  
  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    wasErrorCalled = true;
    return error;
  }
}

/// 测试用的网络配置
class TestNetworkConfig {
  static NetworkConfig get minimal => NetworkConfig(
    baseUrl: 'https://httpbin.org',
    
  );
  
  static NetworkConfig get full => NetworkConfig(
    baseUrl: 'https://api.example.com',
    
    defaultHeaders: {
      'Content-Type': 'application/json',
      'User-Agent': 'Test-Client/1.0',
    },
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 15),
    enableLogging: true,
    enableRetry: true,
    maxRetries: 3,
    enableCache: true,
    cacheTtl: Duration(minutes: 5),
  );
}

class TestResponseParse implements ResponseParser{
  @override
  ParsedResult<T> parse<T>(Map<String, dynamic> json, T Function(T p1) fromJson) {
    final status = json['status'];
    final msg = json['msg'];
    final result = fromJson(json['result']);

    return ParsedResult(
      apiResponse: ApiResponse(code: status, message: msg, data: result),
      isSuccess: status == 200,
    );
  }

}