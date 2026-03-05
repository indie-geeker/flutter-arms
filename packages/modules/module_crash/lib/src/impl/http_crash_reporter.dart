import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:interfaces/crash/i_crash_reporter.dart';
import 'package:interfaces/network/i_http_client.dart';

/// HTTP crash reporter.
///
/// Sends crash data as JSON to a configured endpoint via [IHttpClient].
/// Suitable for custom crash ingestion backends.
class HttpCrashReporter implements ICrashReporter {
  final IHttpClient _httpClient;
  final String _endpoint;
  String? _userId;

  /// Creates an HTTP crash reporter.
  ///
  /// [httpClient] HTTP client for sending reports.
  /// [endpoint] URL path/endpoint to POST crash data to.
  HttpCrashReporter({
    required IHttpClient httpClient,
    required String endpoint,
  })  : _httpClient = httpClient,
        _endpoint = endpoint;

  @override
  Future<void> recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      final payload = <String, dynamic>{
        'error': error.toString(),
        'stackTrace': stackTrace?.toString(),
        'userId': _userId,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        if (context != null) 'context': context,
      };

      await _httpClient.post(
        _endpoint,
        data: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      // Crash reporter should not throw.
      debugPrint('[CrashReporter] Failed to send report: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
  }

  @override
  Future<void> log(String message, {String? category}) async {
    // HTTP reporter doesn't accumulate breadcrumbs locally.
    // Override this to buffer and include breadcrumbs in recordError.
    debugPrint('[CrashReporter] Log: ${category != null ? '[$category] ' : ''}$message');
  }
}

