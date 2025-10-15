/// 存储模块接口导出文件
///
/// 统一导出所有存储相关接口，方便使用方通过单一导入获取所有存储接口。
library;

// 核心存储接口
export 'i_storage.dart';

// 键值存储接口
export 'i_key_value_storage.dart';
export 'i_secure_key_value_storage.dart';

// 对象存储接口
export 'i_object_storage.dart';
export 'i_secure_object_storage.dart';

