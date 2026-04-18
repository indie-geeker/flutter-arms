import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should use env base url when creating dio client', () {
    AppEnv.setup(flavor: AppFlavor.dev);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio.options.baseUrl, AppEnv.current.baseUrl);
    expect(dio.interceptors, isNotEmpty);
  });
}
