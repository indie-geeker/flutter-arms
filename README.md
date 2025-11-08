项目目标

构建一个 Flutter 多平台基础框架（monorepo 结构），主要用于 快速搭建应用项目的底层基础设施，并支持业务模块的灵活替换和扩展。
框架应具备高内聚、低耦合的特性，符合 Clean Architecture 和 插件化原则。

⸻


架构层次

1. interfaces —— 抽象定义层
   •	定义各类功能模块的接口（例如：网络、缓存、日志、存储等）。
   •	不包含任何实现逻辑。
   •	仅描述契约（interface / abstract class）。
   •	为业务层和基础设施层提供稳定依赖。

2. modules —— 基础设施实现层
   •	提供对接口的具体实现，如：
   •	网络模块：dio 或 http 实现。
   •	缓存模块：hive、shared_preferences 实现。
   •	日志模块：logger 或自定义实现。
   •	不包含任何业务逻辑。
   •	通过依赖注入（DI）或插件注册方式接入 core。

3. core —— 聚合与协调层
   •	管理各模块实例的依赖注册与初始化。
   •	对外暴露统一接口，用于 app 层调用。
   •	通过配置（或注解机制）选择不同实现。

4. app —— 应用层
   •	包含业务逻辑与 UI。
   •	依赖 core 提供的能力（网络、存储、日志等）。
   •	可根据不同产品或平台定制模块实现。

目录结构示例
packages/
├── core/
│
├── interfaces/
│   ├── lib/
│   │   ├── network/
│   │   ├── cache/
│   │   ├── logger/
│   │   └── storage/
│
├── modules/
│   ├── module_network/
│   ├── module_cache/
│   ├── module_logger/
│
└── app


关键设计特点
1. 接口隔离原则

每个基础设施功能都有独立的接口定义
应用层只依赖接口，不关心具体实现
便于单元测试和Mock

2. 依赖注入配置

在聚合层统一配置所有依赖
使用Riverpod进行依赖管理
支持不同环境的配置切换

3. 模块化设计

基础设施可独立开发和测试
支持按需引入功能模块
便于团队协作（虽然你是独立开发）

4. 扩展性设计

新增基础设施：

在interfaces中定义接口
在modules下实现
在core中注册
应用层即可使用


替换实现：
创建新的modules/implementation
在应用层初始化时注册模块
