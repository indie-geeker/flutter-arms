/// Cache policy.
enum CachePolicy {
  /// Normal cache — has expiration time, stored in memory + disk.
  normal,

  /// Memory-only cache — cleared when the process exits.
  memoryOnly,

  /// Persistent cache — never expires, but can be manually deleted.
  persistent,

  /// Network-first — prefers network, falls back to cache on failure.
  networkFirst,

  /// Cache-first — uses cache when valid, skips network requests.
  cacheFirst,
}
