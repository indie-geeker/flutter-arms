import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/app_network.dart';

/// Fluent DSL for configuring network interceptors.
///
/// This class provides a clean, fluent API for setting up common
/// network interceptors without verbose boilerplate code.
///
/// Example:
/// ```dart
/// final setup = NetworkSetup()
///   .withResponseParser(MyParser())
///   .withDeduplication()
///   .addInterceptor(MyCustomInterceptor());
/// ```
class NetworkSetup {
  final List<IRequestInterceptor> _interceptors = [];

  /// Default constructor for NetworkSetup.
  NetworkSetup();

  /// Gets the configured interceptors.
  List<IRequestInterceptor> get interceptors => List.unmodifiable(_interceptors);

  /// Adds a response parser interceptor.
  ///
  /// This interceptor will parse API responses according to your
  /// custom response format.
  ///
  /// Parameters:
  /// - [parser]: Custom ResponseParser implementation
  NetworkSetup withResponseParser(ResponseParser parser) {
    _interceptors.add(ResponseParserInterceptor(parser));
    return this;
  }

  /// Adds a request deduplication interceptor.
  ///
  /// This prevents duplicate requests from being sent within
  /// the specified time window.
  ///
  /// Parameters:
  /// - [expiration]: Time window for deduplication (default: 5 minutes)
  NetworkSetup withDeduplication({
    Duration expiration = const Duration(minutes: 5),
  }) {
    _interceptors.add(DeduplicationInterceptor(
      expirationDuration: expiration,
    ));
    return this;
  }

  /// Adds a custom interceptor.
  ///
  /// Use this for any custom interceptor not covered by the
  /// convenience methods above.
  ///
  /// Parameters:
  /// - [interceptor]: Custom IRequestInterceptor implementation
  NetworkSetup addInterceptor(IRequestInterceptor interceptor) {
    _interceptors.add(interceptor);
    return this;
  }

  /// Creates a standard network setup with common interceptors.
  ///
  /// This preset includes:
  /// - Response parser
  /// - Request deduplication
  ///
  /// Parameters:
  /// - [parser]: Custom ResponseParser implementation
  /// - [deduplicationWindow]: Time window for deduplication (default: 5 minutes)
  ///
  /// Example:
  /// ```dart
  /// NetworkSetup.standard(
  ///   parser: MyResponseParser(),
  ///   deduplicationWindow: Duration(minutes: 3),
  /// )
  /// ```
  factory NetworkSetup.standard({
    required ResponseParser parser,
    Duration deduplicationWindow = const Duration(minutes: 5),
  }) {
    return NetworkSetup()
        .withResponseParser(parser)
        .withDeduplication(expiration: deduplicationWindow);
  }

  /// Creates a minimal network setup with no interceptors.
  ///
  /// Use this when you want to start with a clean slate and
  /// add interceptors selectively.
  factory NetworkSetup.minimal() {
    return NetworkSetup();
  }
}
