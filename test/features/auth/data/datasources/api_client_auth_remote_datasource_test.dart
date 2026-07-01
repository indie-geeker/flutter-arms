import 'package:flutter_arms/core/network/api_client.dart';
import 'package:flutter_arms/core/network/api_request.dart';
import 'package:flutter_arms/features/auth/data/datasources/api_client_auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeApiClient implements ApiClient {
  final sent = <ApiRequest<dynamic>>[];
  final _responses = <Object?>[];

  @override
  String get adapterName => 'fake';

  void queueResponse(Object? response) {
    _responses.add(response);
  }

  @override
  Future<T> send<T>(ApiRequest<T> request) async {
    sent.add(request);
    return request.decode(_responses.removeAt(0));
  }
}

void main() {
  late _FakeApiClient client;
  late ApiClientAuthRemoteDataSource dataSource;

  setUp(() {
    client = _FakeApiClient();
    dataSource = ApiClientAuthRemoteDataSource(client);
  });

  group('ApiClientAuthRemoteDataSource', () {
    test('login sends a stable app-level request and decodes token', () async {
      final body = <String, dynamic>{
        'username': 'alice',
        'password': 'secret',
      };
      client.queueResponse(<String, dynamic>{
        'accessToken': 'access',
        'refreshToken': 'refresh',
      });

      final token = await dataSource.login(body);

      final request = client.sent.single;
      expect(request.method, ApiMethod.post);
      expect(request.path, '/auth/login');
      expect(request.body, body);
      expect(request.requiresAuth, isFalse);
      expect(token.accessToken, 'access');
      expect(token.refreshToken, 'refresh');
    });

    test('me sends a GET request and decodes user', () async {
      client.queueResponse(<String, dynamic>{
        'id': '1',
        'name': 'Alice',
        'email': 'alice@example.com',
      });

      final user = await dataSource.me();

      final request = client.sent.single;
      expect(request.method, ApiMethod.get);
      expect(request.path, '/auth/me');
      expect(request.requiresAuth, isTrue);
      expect(user.email, 'alice@example.com');
    });

    test('refreshToken sends refresh body and decodes token', () async {
      final body = <String, dynamic>{'refreshToken': 'old-refresh'};
      client.queueResponse(<String, dynamic>{
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
      });

      final token = await dataSource.refreshToken(body);

      final request = client.sent.single;
      expect(request.method, ApiMethod.post);
      expect(request.path, '/auth/refresh');
      expect(request.body, body);
      expect(request.requiresAuth, isFalse);
      expect(token.accessToken, 'new-access');
    });

    test('logout sends a POST request', () async {
      client.queueResponse(null);

      await dataSource.logout();

      final request = client.sent.single;
      expect(request.method, ApiMethod.post);
      expect(request.path, '/auth/logout');
      expect(request.requiresAuth, isFalse);
    });
  });
}
