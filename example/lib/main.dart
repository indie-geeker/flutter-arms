import 'package:app_core/app_core.dart';
import 'package:example/theme/my_theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:app_interfaces/app_interfaces.dart';
import 'config/base_app_config.dart';
import 'config/config_factory.dart';
import 'initialization_screens.dart';
import 'package:app_logger/app_logger.dart';

/// Main entry point for the application.
///
/// This example demonstrates three initialization patterns:
/// 1. Minimal - Auto-configuration (see _initializeAppMinimal)
/// 2. Standard - Common customization (see _initializeAppStandard)
/// 3. Advanced - Full control (see _initializeAppAdvanced)
///
/// Switch between patterns by changing which method is called in _initializeApp().
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load and validate configuration
    debugPrint('Loading application configuration...');
    final appConfig = await ConfigFactory.create();
    debugPrint('Configuration loaded successfully: ${appConfig.environment.name}');

    // Create AppManager instance
    final appManager = AppManager();

    runApp(MyApp(
      appManager: appManager,
      appConfig: appConfig,
    ));
  } catch (e, stackTrace) {
    debugPrint('Failed to load configuration: $e');
    debugPrint('Stack trace: $stackTrace');

    // Show error screen if configuration fails to load
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final AppManager appManager;
  final BaseAppConfig appConfig;

  const MyApp({
    super.key,
    required this.appManager,
    required this.appConfig,
  });

  /// Application initialization method.
  ///
  /// Choose your initialization pattern below:
  /// - _initializeAppMinimal() - Simplest, auto-configures everything
  /// - _initializeAppStandard() - Most common, adds custom interceptors
  /// - _initializeAppAdvanced() - Full control, custom everything
  Future<bool> _initializeApp() async {
    // CHOOSE YOUR PATTERN HERE:
    // return await _initializeAppMinimal();
    return await _initializeAppStandard();
    // return await _initializeAppAdvanced();
  }

  /// Pattern 1: Minimal (Auto-Configuration)
  ///
  /// This is the simplest approach. Everything is auto-configured from appConfig:
  /// - Network client created from INetWorkConfig
  /// - Default storage (SharedPrefsStorage)
  /// - No custom interceptors
  ///
  /// Use this for: Simple apps, prototyping, learning the framework
  ///
  /// Before optimization: 78 lines
  /// After optimization: 10 lines (87% reduction!)
  Future<bool> _initializeAppMinimal() async {
    debugPrint('🚀 Starting minimal initialization...');

    final result = await appManager.initialize(
      AppInitConfig(config: appConfig),
      onProgress: (progress) {
        debugPrint('Progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
      onStepCompleted: (stepName, success) {
        debugPrint('Module [$stepName] ${success ? '✓' : '✗'}');
      },
    );

    debugPrint('Initialization complete: ${result ? '✓' : '✗'}');
    return result;
  }

  /// Pattern 2: Standard (Common Customization)
  ///
  /// This is the recommended approach for most apps. It adds:
  /// - Custom response parser for your API format
  /// - Request deduplication to prevent duplicate calls
  /// - Logger for debugging
  ///
  /// Use this for: Production apps with custom API formats
  ///
  /// Before optimization: 78 lines
  /// After optimization: 20 lines (74% reduction!)
  Future<bool> _initializeAppStandard() async {
    debugPrint('🚀 Starting standard initialization...');
    debugPrint('Environment: ${appConfig.environment.name}');
    debugPrint('API Base URL: ${appConfig.apiBaseUrl}');

    // Create logger with console and memory outputs
    final logger = CompositeLogger(
      outputs: [
        ConsoleLogOutput(),
        MemoryLogOutput(maxEntries: 500),
      ],
      minLevel: LogLevel.debug,
    );

    final result = await appManager.initialize(
      AppInitConfig(
        config: appConfig,
        logger: logger,
        networkSetup: (config) => NetworkSetup.standard(
          parser: TestResponseParser(),
          deduplicationWindow: const Duration(minutes: 5),
        ),
        // ✨ Theme and i18n support
        themeFactory: () => MyThemeManager(
          config: appConfig,
          storage: appManager.tryGetStorage<IKeyValueStorage>(),
        ),
        i18nDelegate: AppI18nDelegate(
          config: I18nConfig.defaults(), // zh_CN + en_US
          logger: logger,
        ),
      ),
      onProgress: (progress) {
        debugPrint('Progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
      onStepCompleted: (stepName, success) {
        debugPrint('Module [$stepName] ${success ? '✓' : '✗'}');
      },
    );

    debugPrint('Initialization complete: ${result ? '✓' : '✗'}');
    return result;
  }

  /// Pattern 3: Advanced (Full Control)
  ///
  /// This pattern gives you complete control over everything:
  /// - Custom storage implementation
  /// - Custom interceptors with specific configuration
  /// - Custom logger
  /// - Custom locales
  ///
  /// Use this for: Complex apps with special requirements
  ///
  /// Before optimization: 78+ lines
  /// After optimization: 30-40 lines (still 50%+ reduction)
  Future<bool> _initializeAppAdvanced() async {
    debugPrint('🚀 Starting advanced initialization...');
    debugPrint('Environment: ${appConfig.environment.name}');
    debugPrint('API Base URL: ${appConfig.apiBaseUrl}');

    final result = await appManager.initialize(
      AppInitConfig(
        config: appConfig,
        logger: CompositeLogger(
          outputs: [
            ConsoleLogOutput(),
            MemoryLogOutput(maxEntries: 1000),
          ],
          minLevel: LogLevel.debug,
        ),
        // Custom storage with encryption
        storageFactory: () => SharedPrefsStorage(
          StorageConfig(
            name: 'secure_storage',
            enableEncryption: appConfig.enableEncryption,
            encryptionKey: 'my-secret-key-32-chars-long!!!',
          ),
          logger: CompositeLogger(
            outputs: [ConsoleLogOutput()],
          ),
        ),
        // Custom network setup with multiple interceptors
        networkSetup: (config) => NetworkSetup.minimal()
            .withResponseParser(TestResponseParser())
            .withDeduplication(expiration: const Duration(minutes: 3))
            .addInterceptor(
              // You can add custom interceptors here
              // e.g., AuthInterceptor(token: myToken)
              ResponseParserInterceptor(TestResponseParser()),
            ),
        // Custom locales
        defaultLocale: const Locale('en', 'US'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
          Locale('ja', 'JP'),
        ],
      ),
      onProgress: (progress) {
        debugPrint('Progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
      onStepCompleted: (stepName, success) {
        debugPrint('Module [$stepName] ${success ? '✓' : '✗'}');
      },
    );

    debugPrint('Initialization complete: ${result ? '✓' : '✗'}');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(
      appManager: appManager,
      child: FutureBuilder<bool>(
        future: _initializeApp(),
        builder: (context, snapshot) {
          // Show loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              title: appConfig.appName,
              debugShowCheckedModeBanner: !appConfig.isProduction,
              home: const InitializationScreen(),
            );
          }

          // Show error state
          if (snapshot.hasError || snapshot.data != true) {
            return MaterialApp(
              title: appConfig.appName,
              debugShowCheckedModeBanner: !appConfig.isProduction,
              home: InitializationErrorScreen(
                error: snapshot.error?.toString() ?? 'Initialization failed',
                onRetry: () {
                  (context as Element).markNeedsBuild();
                },
              ),
            );
          }

          // Initialization successful - build app with theme management
          final themeManager = appManager.themeManager;

          if (themeManager == null) {
            // Fallback: theme manager not initialized, use default theme
            return MaterialApp(
              title: appConfig.appName,
              debugShowCheckedModeBanner: !appConfig.isProduction,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              showPerformanceOverlay: appConfig.showPerformanceOverlay,
              home: MyHomePage(
                title: '${appConfig.appName} - ${appConfig.environment.name}',
              ),
            );
          }

          // Build app with theme management
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: themeManager.themeModeNotifier,
            builder: (context, themeMode, _) {
              return ValueListenableBuilder<Color?>(
                valueListenable: themeManager.themeColorNotifier!,
                builder: (context, themeColor, _) {
                  return MaterialApp(
                    title: appConfig.appName,
                    debugShowCheckedModeBanner: !appConfig.isProduction,
                    themeMode: themeMode,
                    theme: themeManager.lightTheme,
                    darkTheme: themeManager.darkTheme,
                    showPerformanceOverlay: appConfig.showPerformanceOverlay,
                    home: MyHomePage(
                      title: '${appConfig.appName} - ${appConfig.environment.name}',
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  SharedPrefsStorage? _storage;
  String _testValue = 'Loading...';
  Locale _currentLocale = const Locale('zh', 'CN');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_storage == null) {
      _initializeStorage();
    }
    _listenToLocaleChanges();
  }

  void _listenToLocaleChanges() {
    final appManager = AppManagerProvider.of(context);
    final i18n = appManager.i18n;

    if (i18n != null) {
      setState(() {
        _currentLocale = i18n.currentLocale;
      });

      i18n.localeChanges.listen((locale) {
        if (mounted) {
          setState(() {
            _currentLocale = locale;
          });
        }
      });
    }
  }

  Future<void> _initializeStorage() async {
    try {
      final appManager = AppManagerProvider.of(context);
      _storage = appManager.getStorage<SharedPrefsStorage>();

      final savedCounter = await _storage!.getInt('counter', 0);
      final testValue = await _storage!.getString('test', 'No test data found');

      setState(() {
        _counter = savedCounter ?? 0;
        _testValue = testValue ?? 'No test data found';
      });

      debugPrint('Storage initialized: counter=$_counter, test=$_testValue');
    } catch (e) {
      debugPrint('Storage initialization failed: $e');
      setState(() {
        _counter = 0;
        _testValue = 'Storage initialization failed';
      });
    }
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    if (_storage != null) {
      try {
        await _storage!.setInt('counter', _counter);
        debugPrint('Counter saved: $_counter');
      } catch (e) {
        debugPrint('Failed to save counter: $e');
      }
    }
  }

  Future<void> _switchLanguage() async {
    final appManager = AppManagerProvider.of(context);
    final i18n = appManager.i18n;

    if (i18n != null) {
      // Toggle between Chinese and English
      final newLocale = _currentLocale.languageCode == 'zh'
          ? const Locale('en', 'US')
          : const Locale('zh', 'CN');

      final success = await i18n.switchLocale(newLocale);
      if (success) {
        debugPrint('Locale switched to: $newLocale');
      } else {
        debugPrint('Failed to switch locale to: $newLocale');
      }
    }
  }

  String _t(String key, {Map<String, dynamic>? args}) {
    final appManager = AppManagerProvider.of(context);
    final i18n = appManager.i18n;
    return i18n?.translate(key, args: args) ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final appManager = AppManagerProvider.of(context);
    final themeManager = appManager.themeManager;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_t('app_name')),
        actions: [
          // Theme switcher
          if (themeManager != null)
            IconButton(
              icon: Icon(
                themeManager.themeModeNotifier.value == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                final isDark = themeManager.themeModeNotifier.value == ThemeMode.dark;
                themeManager.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
              },
              tooltip: _t('switch_theme'),
            ),
          // Language switcher
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _switchLanguage,
            tooltip: _t('switch_language'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _t('welcome', args: {'name': 'Flutter ARMS'}),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _t('current_environment', args: {'env': widget.title}),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Counter:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              _t('storage_test'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _testValue,
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _switchLanguage,
                  icon: const Icon(Icons.translate),
                  label: Text('${_currentLocale.languageCode.toUpperCase()} → ${_currentLocale.languageCode == 'zh' ? 'EN' : 'ZH'}'),
                ),
                const SizedBox(width: 16),
                if (themeManager != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      final isDark = themeManager.themeModeNotifier.value == ThemeMode.dark;
                      themeManager.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                    icon: Icon(
                      themeManager.themeModeNotifier.value == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    label: Text(_t('switch_theme')),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Test response parser for demonstration.
class TestResponseParser implements ResponseParser {
  @override
  ParsedResult<T> parse<T>(
      Map<String, dynamic> json, T Function(T p1) fromJson) {
    final status = json['status'];
    final msg = json['msg'];
    final result = fromJson(json['result']);

    return ParsedResult(
      apiResponse: ApiResponse(code: status, message: msg, data: result),
      isSuccess: status == 200,
    );
  }
}
