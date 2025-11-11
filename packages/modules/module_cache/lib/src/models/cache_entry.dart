
import 'package:interfaces/cache/cache_policy.dart';

/// 缓存条目
class CacheEntry {
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final CachePolicy policy;
  DateTime lastAccessedAt;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    this.expiresAt,
    required this.policy,
  }) : lastAccessedAt = DateTime.now();

  bool get isExpired {
    if (policy == CachePolicy.persistent) return false;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  void updateAccessTime() {
    lastAccessedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'value': value,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'policy': policy.name,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    key: json['key'],
    value: json['value'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'])
        : null,
    policy: CachePolicy.values.firstWhere(
          (e) => e.name == json['policy'],
      orElse: () => CachePolicy.normal,
    ),
  );
}