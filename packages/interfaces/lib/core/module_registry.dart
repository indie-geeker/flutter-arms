
import 'i_service_locator.dart';

/// 模块注册接口
///
/// 所有功能模块（如 Logger、Storage、Network 等）都需要实现此接口。
/// 通过统一的模块接口，Core 层可以协调各模块的注册、初始化和销毁流程。
abstract class IModule {
  /// 模块名称（用于日志和调试）
  String get name;

  /// 初始化优先级（数字越小优先级越高）
  ///
  /// 例如：
  /// - Logger: 10 (最先初始化)
  /// - Storage: 20
  /// - Cache: 30 (依赖 Storage)
  /// - Network: 40 (依赖 Cache)
  int get priority;

  /// 模块依赖列表
  ///
  /// 声明当前模块依赖的其他服务类型。
  /// Core 层会在初始化前验证依赖关系，确保依赖的服务已注册。
  List<Type> get dependencies;

  /// 模块提供的服务类型列表
  ///
  /// 用于依赖图解析与初始化排序，确保依赖模块先于使用模块初始化。
  /// 例如 LoggerModule 提供 ILogger，StorageModule 提供 IKeyValueStorage。
  List<Type> get provides;

  /// 注册模块服务
  ///
  /// 将模块提供的服务注册到服务定位器中。
  ///
  /// **重要**：此方法接收 [IServiceLocator] 接口，而不是具体实现。
  /// 这样模块层只需要依赖 `interfaces` 包，不需要依赖 `core` 包。
  Future<void> register(IServiceLocator locator);

  /// 初始化模块
  ///
  /// 执行模块的初始化逻辑（如打开数据库、建立网络连接等）。
  /// 在所有模块的 register 方法执行完后，按优先级依次调用。
  Future<void> init();

  /// 销毁模块
  ///
  /// 清理模块资源（如关闭数据库、取消网络请求等）。
  /// 应用退出时按优先级逆序调用。
  Future<void> dispose();
}

class InitPriorities{
  static const int logger = 0;
  static const int storage = 10;
  static const int cache = 30;
  static const int network = 40;
  static const int theme = 50;
}
