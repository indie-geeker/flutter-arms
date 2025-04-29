import '../../domain/entities/user.dart';

//概念层面：
// Entity（实体）：
// 代表领域模型中的核心业务概念
// 包含业务规则和业务逻辑
// 与数据库结构无关
// 属于领域层（Domain Layer）

// Model（模型）：
// 主要用于数据传输和持久化
// 通常是数据结构的直接映射
// 与具体数据源格式紧密相关
// 属于数据层（Data Layer）


//主要区别：
//依赖方向：
//Entity 不依赖于外部框架和库
//Model 可能依赖于序列化库（如 json_serializable）
//职责：
//Entity 包含业务逻辑和规则
//Model 负责数据转换和持久化
//使用场景：
//Entity 在业务逻辑中使用
//Model 在数据访问层使用

//清晰分层：
//Entity 放在 domain/entities 目录
//Model 放在 data/models 目录
//转换规则：
//Model 应该提供 toEntity() 方法
//避免在 Entity 中引用 Model
//命名约定：
//Entity 类名使用领域术语（如 User）
//Model 类名添加 Model 后缀（如 UserModel）
//测试策略：
//Entity 测试关注业务逻辑
//Model 测试关注序列化/反序列化

//这种分离可以带来以下好处：
//更好的关注点分离
//更容易测试和维护
//更灵活的数据源切换
//更清晰的代码组织
//更好的业务逻辑封装

class UserModel {
  final String id;
  final String username;
  final String email;
  final String roleStr;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.roleStr,
  });

  // 序列化方法
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      roleStr: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': roleStr,
    };
  }

  // 转换为领域实体
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == roleStr,
        orElse: () => UserRole.user,
      ),
    );
  }
}