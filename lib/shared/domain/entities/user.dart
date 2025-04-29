class User {
  final String id;
  final String username;
  final String email;
  final UserRole role;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  // 业务逻辑方法
  bool canAccessAdminPanel() {
    return role == UserRole.admin;
  }

  bool isValidEmail() {
    return email.contains('@') && email.contains('.');
  }
}

enum UserRole { user, admin, moderator }