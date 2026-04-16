/// 用户实体（Domain 层，纯 Dart）。
class User {
  /// 构造函数。
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  /// 用户 ID。
  final String id;

  /// 用户名。
  final String name;

  /// 邮箱。
  final String email;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is User && other.id == id && other.name == name && other.email == email;
  }

  @override
  int get hashCode => Object.hash(id, name, email);
}
