export 'src/app_manager.dart';
export 'src/app_manager_provider.dart';
export 'src/app_init_config.dart';

/// Builders
export 'src/builders/network_client_builder.dart';
export 'src/config/app_init_config_builder.dart';

/// Setup DSLs
export 'src/setup/network_setup.dart';

/// Constants
export 'src/constants/init_priorities.dart';

/// i18n
export 'src/i18n/app_i18n_delegate.dart';

/// Extensions
export 'src/extensions/config_extensions.dart';
/// 通用接口
export 'package:app_interfaces/app_interfaces.dart'
    show
        ResponseParser,
        ParsedResult,
        ApiResponse,
        BaseConfig,
        ConfigValidator,
        ValidationResult,
        CompositeValidator,
        NoOpValidator,
        NetworkConfigValidator,
        StorageConfigValidator,
        EnvironmentType,
        IEnvironmentConfig,
        INetWorkConfig,
        LogLevel,
        ILogger,
        LogEntry,
        II18nDelegate,
        SimpleI18nDelegate,
        I18nConfig;

/// 存储
export 'package:app_storage/app_storage.dart' show SharedPrefsStorage, StorageConfig;

/// 网络
export 'package:app_network/app_network.dart'
    show
        NetworkClientFactory,
        NetworkConfig,
        NetworkClient,
        ResponseParserInterceptor,
        DeduplicationInterceptor;

/// 日志
export 'package:app_logger/app_logger.dart' show CompositeLogger, ConsoleLogOutput, MemoryLogOutput;
