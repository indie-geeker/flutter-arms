import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

import 'config/base_app_config.dart';
import 'config/config_factory.dart';
import 'initialization_screens.dart';

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

    const testUrl = "http://www.baidu.com";

    final result = await appManager.initialize(
      AppInitConfig(
        config: appConfig,
        logger: Logger(),
        networkSetup: (config) => NetworkSetup.standard(
          parser: TestResponseParser(),
          deduplicationWindow: const Duration(minutes: 5),
        ),
      ),
      onProgress: (progress) {
        debugPrint('Progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
      onStepCompleted: (stepName, success) {
        debugPrint('Module [$stepName] ${success ? '✓' : '✗'}');

        // Test network request after network module is initialized
        if (stepName == "app_network" && success) {
          appManager.networkClient.get(testUrl).then((response) {
            debugPrint(
                "✓ Network test: ${response.code} ${response.message} ${jsonEncode(response.data)}");
          }).catchError((error) {
            debugPrint("✗ Network test failed: ${error.toString()}");
          });
        }
      },
    );

    // Test storage after initialization
    if (result) {
      try {
        final storage = appManager.getStorage<SharedPrefsStorage>();
        await storage.setString(
            "test", "App initialized - ${DateTime.now().toIso8601String()}");
        await storage.setString("app_version", "2.0.0");
        await storage.setInt("launch_count", 1);
        debugPrint('✓ Storage test successful');
      } catch (e) {
        debugPrint('✗ Storage test failed: $e');
      }
    }

    // Add delay to show loading screen
    debugPrint('Waiting 2 seconds to display loading effect...');
    await Future.delayed(const Duration(seconds: 2));

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

    const testUrl = "http://www.baidu.com";

    final result = await appManager.initialize(
      AppInitConfig(
        config: appConfig,
        logger: Logger(minLevel: LogLevel.debug),
        // Custom storage with encryption
        storageFactory: () => SharedPrefsStorage(
          StorageConfig(
            name: 'secure_storage',
            enableEncryption: appConfig.enableEncryption,
            encryptionKey: 'my-secret-key-32-chars-long!!!',
          ),
          logger: Logger(),
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

        if (stepName == "app_network" && success) {
          appManager.networkClient.get(testUrl).then((response) {
            debugPrint(
                "✓ Network test: ${response.code} ${response.message}");
          }).catchError((error) {
            debugPrint("✗ Network test failed: ${error.toString()}");
          });
        }
      },
    );

    if (result) {
      try {
        final storage = appManager.getStorage<SharedPrefsStorage>();
        await storage.setString(
            "test", "Advanced init - ${DateTime.now().toIso8601String()}");
        debugPrint('✓ Encrypted storage test successful');
      } catch (e) {
        debugPrint('✗ Storage test failed: $e');
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    debugPrint('Initialization complete: ${result ? '✓' : '✗'}');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(
      appManager: appManager,
      child: MaterialApp(
        title: appConfig.appName,
        debugShowCheckedModeBanner: !appConfig.isProduction,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        showPerformanceOverlay: appConfig.showPerformanceOverlay,
        home: FutureBuilder<bool>(
          future: _initializeApp(),
          builder: (context, snapshot) {
            // Show loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const InitializationScreen();
            }

            // Show error state
            if (snapshot.hasError || snapshot.data != true) {
              return InitializationErrorScreen(
                error: snapshot.error?.toString() ?? 'Initialization failed',
                onRetry: () {
                  (context as Element).markNeedsBuild();
                },
              );
            }

            // Show success - main app screen
            return MyHomePage(
              title: '${appConfig.appName} - ${appConfig.environment.name}',
            );
          },
        ),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_storage == null) {
      _initializeStorage();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stored test data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _testValue,
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
            const SizedBox(height: 20),

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
