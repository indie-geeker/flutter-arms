# flutter_arms

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

lib/
├── core/                   # 框架级的核心功能
│   ├── constants/          # 常量
│   ├── errors/             # 错误处理
│   ├── network/            # 网络请求
│   └── utils/              # 工具函数
├── shared/                 # 共享业务功能
│   ├── data/               # 共享数据层
│   │   ├── models/         # 共享数据模型
│   │   │   ├── user_model.dart
│   │   │   └── config_model.dart
│   │   └── repositories/   # 共享仓库实现
│   │       └── shared_repository_impl.dart
│   ├── domain/             # 共享领域层
│   │   ├── entities/       # 共享实体
│   │   │   ├── user.dart
│   │   │   └── config.dart
│   │   ├── repositories/   # 共享仓库接口
│   │   │   └── shared_repository.dart
│   │   └── usecases/       # 共享用例
│   │       ├── auth_usecases.dart
│   │       └── config_usecases.dart
│   ├── presentation/       # 共享UI组件lib/
  core/
    functional/
      either.dart
│   │   ├── providers/      # 共享状态管理
│   │   │   ├── auth_provider.dart
│   │   │   └── theme_provider.dart
│   │   └── widgets/        # 共享组件
│   │       ├── buttons/
│   │       ├── dialogs/
│   │       └── forms/
│   └── services/           # 共享服务
│       ├── analytics/      # 分析服务
│       ├── storage/        # 存储服务
│       └── permissions/    # 权限服务
├── features/               # 具体业务功能模块
├── config/                 # 配置
└── main.dart
