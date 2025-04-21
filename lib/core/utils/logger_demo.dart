import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'logger_util.dart';

/// 日志演示页面
class LoggerDemoPage extends StatefulWidget {
  const LoggerDemoPage({Key? key}) : super(key: key);

  @override
  State<LoggerDemoPage> createState() => _LoggerDemoPageState();
}

class _LoggerDemoPageState extends State<LoggerDemoPage> {
  final List<String> _logEntries = [];
  bool _verboseEnabled = true;
  bool _debugEnabled = true;
  bool _infoEnabled = true;
  bool _warningEnabled = true;
  bool _errorEnabled = true;

  @override
  void initState() {
    super.initState();
    _configureLogger();
  }

  /// 配置日志记录器
  void _configureLogger() {
    // 使用自定义的日志输出，将日志同时显示在控制台和UI上
    logger.reconfigure(
      level: Level.trace,
      printer: SimplePrinter(printTime: true),
      output: _CustomLogOutput(
        onLog: (String log) {
          setState(() {
            _logEntries.add(log);
            // 限制日志条目数量，避免内存占用过多
            if (_logEntries.length > 100) {
              _logEntries.removeAt(0);
            }
          });
        },
      ),
    );
    // 根据当前日志级别更新UI状态
    _updateUIFromLogLevel(logger.currentLevel);
  }

  /// 根据日志级别更新UI状态
  void _updateUIFromLogLevel(Level level) {
    setState(() {
      _verboseEnabled = level.index <= Level.verbose.index;
      _debugEnabled = level.index <= Level.debug.index;
      _infoEnabled = level.index <= Level.info.index;
      _warningEnabled = level.index <= Level.warning.index;
      _errorEnabled = level.index <= Level.error.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _logEntries.clear();
              });
            },
            tooltip: '清除日志',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLogControls(),
          _buildLogButtons(),
          Expanded(
            child: _buildLogList(),
          ),
        ],
      ),
    );
  }

  /// 构建日志级别控制开关
  Widget _buildLogControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          _buildLogLevelSwitch('详细', _verboseEnabled, (value) {
            setState(() {
              _verboseEnabled = value;
              _updateLogLevel();
            });
          }),
          _buildLogLevelSwitch('调试', _debugEnabled, (value) {
            setState(() {
              _debugEnabled = value;
              _updateLogLevel();
            });
          }),
          _buildLogLevelSwitch('信息', _infoEnabled, (value) {
            setState(() {
              _infoEnabled = value;
              _updateLogLevel();
            });
          }),
          _buildLogLevelSwitch('警告', _warningEnabled, (value) {
            setState(() {
              _warningEnabled = value;
              _updateLogLevel();
            });
          }),
          _buildLogLevelSwitch('错误', _errorEnabled, (value) {
            setState(() {
              _errorEnabled = value;
              _updateLogLevel();
            });
          }),
        ],
      ),
    );
  }

  /// 构建单个日志级别开关
  Widget _buildLogLevelSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 更新日志级别
  void _updateLogLevel() {
    Level level;
    if (_verboseEnabled) {
      level = Level.verbose;
    } else if (_debugEnabled) {
      level = Level.debug;
    } else if (_infoEnabled) {
      level = Level.info;
    } else if (_warningEnabled) {
      level = Level.warning;
    } else if (_errorEnabled) {
      level = Level.error;
    } else {
      level = Level.nothing;
    }
    logger.reconfigure(level: level);
  }

  /// 构建日志操作按钮
  Widget _buildLogButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          ElevatedButton(
            onPressed: _logVerbose,
            child: const Text('详细日志'),
          ),
          ElevatedButton(
            onPressed: _logDebug,
            child: const Text('调试日志'),
          ),
          ElevatedButton(
            onPressed: _logInfo,
            child: const Text('信息日志'),
          ),
          ElevatedButton(
            onPressed: _logWarning,
            child: const Text('警告日志'),
          ),
          ElevatedButton(
            onPressed: _logError,
            child: const Text('错误日志'),
          ),
          ElevatedButton(
            onPressed: _logException,
            child: const Text('异常日志'),
          ),
        ],
      ),
    );
  }

  /// 构建日志列表
  Widget _buildLogList() {
    return ListView.builder(
      itemCount: _logEntries.length,
      itemBuilder: (context, index) {
        final log = _logEntries[_logEntries.length - 1 - index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(log),
          ),
        );
      },
    );
  }

  /// 记录详细日志
  void _logVerbose() {
    logger.v('这是一条详细日志，通常用于详细的调试信息');
  }

  /// 记录调试日志
  void _logDebug() {
    logger.d('这是一条调试日志，用于一般调试信息');
  }

  /// 记录信息日志
  void _logInfo() {
    logger.i('这是一条信息日志，表示程序正常运行');
  }

  /// 记录警告日志
  void _logWarning() {
    logger.w('这是一条警告日志，表示可能的问题');
  }

  /// 记录错误日志
  void _logError() {
    logger.e('这是一条错误日志，表示程序出现错误');
  }

  /// 记录异常日志
  void _logException() {
    try {
      // 故意抛出异常
      throw Exception('这是一个测试异常');
    } catch (e, stackTrace) {
      logger.e('捕获到异常', e, stackTrace);
    }
  }
}

/// 自定义日志输出
class _CustomLogOutput extends LogOutput {
  final Function(String) onLog;

  _CustomLogOutput({required this.onLog});

  @override
  void output(OutputEvent event) {
    // 输出到控制台
    for (var line in event.lines) {
      print(line);
      onLog(line);
    }
  }
}
