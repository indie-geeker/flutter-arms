import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';

/// Remote output implementation that sends log entries to a remote server.
///
/// This output batches log entries and sends them to a remote endpoint at
/// regular intervals or when the batch size is reached. This helps reduce
/// network overhead while ensuring timely delivery of critical logs.
///
/// Example usage:
/// ```dart
/// final networkClient = DioClient();
/// final remoteOutput = RemoteLogOutput(
///   networkClient,
///   endpoint: 'https://api.example.com/logs',
///   batchInterval: Duration(seconds: 30),
///   batchSize: 50,
/// );
/// final logger = CompositeLogger(outputs: [remoteOutput]);
/// logger.info('This will be sent to the remote server');
///
/// // Don't forget to dispose when done
/// remoteOutput.dispose();
/// ```
class RemoteLogOutput implements LogOutput {
  /// Network client for sending logs
  final INetworkClient _client;

  /// Remote endpoint URL
  final String endpoint;

  /// How often to send batched logs
  final Duration batchInterval;

  /// Maximum number of logs to batch before sending
  final int batchSize;

  /// Queue of pending log entries
  final Queue<LogEntry> _pendingLogs = Queue<LogEntry>();

  /// Timer for periodic batch sending
  Timer? _timer;

  /// Whether the output has been disposed
  bool _isDisposed = false;

  /// Lock to prevent concurrent sends
  bool _isSending = false;

  /// Creates a remote log output.
  ///
  /// [_client] Network client implementation for sending HTTP requests
  /// [endpoint] The remote endpoint URL where logs will be sent
  /// [batchInterval] How often to send batched logs. Defaults to 30 seconds
  /// [batchSize] Maximum number of logs to batch before sending. Defaults to 50
  RemoteLogOutput(
    this._client, {
    required this.endpoint,
    this.batchInterval = const Duration(seconds: 30),
    this.batchSize = 50,
  }) {
    _startTimer();
  }

  @override
  void write(LogEntry entry) {
    if (_isDisposed) {
      return;
    }

    try {
      _pendingLogs.add(entry);

      // Send immediately if batch size is reached
      if (_pendingLogs.length >= batchSize) {
        _sendBatch();
      }
    } catch (e) {
      debugPrint('RemoteLogOutput write error: $e');
    }
  }

  /// Starts the periodic timer for sending batched logs.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(batchInterval, (_) {
      _sendBatch();
    });
  }

  /// Sends the current batch of logs to the remote server.
  Future<void> _sendBatch() async {
    // Prevent concurrent sends
    if (_isSending || _pendingLogs.isEmpty || _isDisposed) {
      return;
    }

    _isSending = true;

    try {
      // Take all pending logs
      final logsToSend = List<LogEntry>.from(_pendingLogs);
      _pendingLogs.clear();

      // Convert to JSON
      final payload = {
        'logs': logsToSend.map(_entryToJson).toList(),
        'sentAt': DateTime.now().toIso8601String(),
      };

      // Send to server
      await _client.post(
        endpoint,
        data: jsonEncode(payload),
      );
    } catch (e) {
      // On error, put logs back in queue for retry
      debugPrint('RemoteLogOutput send error: $e');
      // Note: We don't re-add logs to avoid infinite growth on persistent errors
      // In production, you might want to implement a more sophisticated retry strategy
    } finally {
      _isSending = false;
    }
  }

  /// Converts a log entry to a JSON map.
  Map<String, dynamic> _entryToJson(LogEntry entry) {
    final json = <String, dynamic>{
      'timestamp': entry.timestamp.toIso8601String(),
      'level': entry.level.toString().split('.').last,
      'message': entry.message,
    };

    if (entry.tag != null) {
      json['tag'] = entry.tag;
    }

    if (entry.error != null) {
      json['error'] = entry.error.toString();
    }

    if (entry.stackTrace != null) {
      json['stackTrace'] = entry.stackTrace.toString();
    }

    return json;
  }

  /// Flushes all pending logs immediately.
  ///
  /// This forces the output to send all queued logs to the remote server
  /// without waiting for the batch interval or size threshold.
  ///
  /// Returns a Future that completes when the logs have been sent.
  Future<void> flush() async {
    await _sendBatch();
  }

  /// Gets the number of pending logs waiting to be sent.
  int get pendingCount => _pendingLogs.length;

  /// Disposes of this output and cancels the periodic timer.
  ///
  /// Should be called when the logger is no longer needed to prevent
  /// resource leaks. Optionally flushes pending logs before disposing.
  ///
  /// [flushBeforeDispose] Whether to send pending logs before disposing.
  /// Defaults to true.
  Future<void> dispose({bool flushBeforeDispose = true}) async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _timer?.cancel();
    _timer = null;

    if (flushBeforeDispose) {
      await flush();
    }

    _pendingLogs.clear();
  }
}
