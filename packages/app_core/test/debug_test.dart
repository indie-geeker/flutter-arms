import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:app_core/src/app_info.dart';
import 'helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('调试 AppInfo 初始化', () {
    test('直接测试 AppInfo 初始化', () async {
      final mockStorage = TestHelpers.createMockKeyValueStorage();
      
      // 确保存储已初始化
      await mockStorage.init();
      
      final appInfo = AppInfo(
        channel: 'test',
        storage: mockStorage,
      );
      
      try {
        await appInfo.initialize();
        debugPrint('AppInfo 初始化成功');

        // 验证基本属性
        debugPrint('App Name: ${appInfo.appName}');
        debugPrint('Package Name: ${appInfo.packageName}');
        debugPrint('Version: ${appInfo.version}');
        debugPrint('Channel: ${appInfo.channel}');

      } catch (e, stackTrace) {
        debugPrint('AppInfo 初始化失败: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    });
    
    test('测试存储操作', () async {
      final mockStorage = TestHelpers.createMockKeyValueStorage();
      await mockStorage.init();
      
      // 测试存储基本操作
      await mockStorage.setString('test_key', 'test_value');
      final value = await mockStorage.getString('test_key');
      
      expect(value, equals('test_value'));
      debugPrint('存储操作正常');
    });
  });
}
