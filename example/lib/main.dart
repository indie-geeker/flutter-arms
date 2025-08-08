import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:app_storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'initialization_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 应用初始化方法
  Future<bool> _initializeApp() async {
    // 添加延迟以便观察加载状态
    debugPrint('开始应用初始化...');
    var testUrl = "http://www.baidu.com";
    final result = await AppManager.instance.initialize(
      AppConfig.development(
        channel: "dev",
        storageFactory: () => SharedPrefsStorage(StorageConfig.defaultConfig()),
        networkClientFactory: () => NetworkClientFactory.create(
          config: NetworkConfig.development(
            baseUrl: testUrl,
            parser: TestResponseParser(),
          ),
        ),
      ),
      onProgress: (progress) {
        debugPrint('初始化进度: ${(progress * 100).toStringAsFixed(0)}%');
      },
      onStepCompleted: (stepName, success) {
        debugPrint('模块[$stepName]初始化${success ? '成功' : '失败'}');

        if (stepName == "app_network" && success) {
          AppManager.instance.networkClient.get(testUrl).then((v) {
            debugPrint(
                "network请求成功: ${v.code}  ${v.message}  ${jsonEncode(v.data)}");
          }).catchError((error) {
            debugPrint("network请求失败: ${error.toString()}");
          });
        }
      },
    );

    NetworkClient(
            config:
                NetworkConfig(baseUrl: testUrl, parser: TestResponseParser()))
        .get(testUrl)
        .then((v) {
      debugPrint("network: ${v.code}   ${v.message}  ${jsonEncode(v.data)}");
    });

    // 添加2秒延迟，让用户能看到加载界面
    debugPrint('初始化完成，等待2秒以显示加载效果...');
    await Future.delayed(const Duration(seconds: 2));

    // 初始化完成后进行存储操作
    if (result) {
      try {
        final storage = AppManager.instance.getStorage<SharedPrefsStorage>();
        await storage.setString(
            "test", "应用初始化完成 - ${DateTime.now().toIso8601String()}");
        await storage.setString("app_version", "1.0.0");
        await storage.setInt("launch_count", 1);
        debugPrint('初始化完成后的存储操作成功');
      } catch (e) {
        debugPrint('初始化完成后的存储操作失败: $e');
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Arms Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _initializeApp(),
        builder: (context, snapshot) {
          // 显示加载状态
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const InitializationScreen();
          }

          // 初始化失败
          if (snapshot.hasError || snapshot.data != true) {
            return InitializationErrorScreen(
              error: snapshot.error?.toString() ?? '初始化失败',
              onRetry: () {
                // 重新构建 widget 以重试初始化
                (context as Element).markNeedsBuild();
              },
            );
          }

          // 初始化成功，显示主页面
          return const MyHomePage(title: 'Flutter Arms Demo');
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  SharedPrefsStorage? _storage;
  String _testValue = '加载中...'; // 添加状态变量存储测试值

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  /// 使用泛型方法初始化存储
  Future<void> _initializeStorage() async {
    try {
      // 使用泛型方法获取键值存储实例 - 类型安全，无需强制转换
      _storage = AppManager.instance.getStorage<SharedPrefsStorage>();

      // 从存储中加载计数器值
      final savedCounter = await _storage!.getInt('counter', 0);

      // 加载测试值
      final testValue = await _storage!.getString('test', '未找到测试数据');

      setState(() {
        _counter = savedCounter ?? 0;
        _testValue = testValue ?? '未找到测试数据';
      });

      debugPrint('存储初始化成功，加载计数器值: $_counter, 测试值: $_testValue');
    } catch (e) {
      debugPrint('存储初始化失败: $e');
      // 如果存储不可用，使用默认值
      setState(() {
        _counter = 0;
        _testValue = '存储初始化失败';
      });
    }
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    // 保存计数器值到存储
    if (_storage != null) {
      try {
        await _storage!.setInt('counter', _counter);
        debugPrint('计数器值已保存: $_counter');
      } catch (e) {
        debugPrint('保存计数器值失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 方法必须是同步的，不能使用 await
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
              '存储的测试数据:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _testValue, // 使用状态变量，而不是异步调用
              style: const TextStyle(fontSize: 14, color: Colors.blue),
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
