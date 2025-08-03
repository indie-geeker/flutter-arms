import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_interfaces/app_interfaces.dart';

import '../lib/src/app_info.dart';
import 'mocks/mock_storage.dart';
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
        print('AppInfo 初始化成功');
        
        // 验证基本属性
        print('App Name: ${appInfo.appName}');
        print('Package Name: ${appInfo.packageName}');
        print('Version: ${appInfo.version}');
        print('Channel: ${appInfo.channel}');
        
      } catch (e, stackTrace) {
        print('AppInfo 初始化失败: $e');
        print('Stack trace: $stackTrace');
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
      print('存储操作正常');
    });
  });
}
