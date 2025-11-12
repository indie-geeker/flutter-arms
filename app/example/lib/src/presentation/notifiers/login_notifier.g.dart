// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loginNotifierHash() => r'0df2b03bd7d5e169ae49935f9e5aa729a4e2401a';

/// 登录状态管理器
///
/// 使用 Riverpod annotation 定义状态管理
///
/// Copied from [LoginNotifier].
@ProviderFor(LoginNotifier)
final loginNotifierProvider =
    AutoDisposeNotifierProvider<LoginNotifier, LoginState>.internal(
      LoginNotifier.new,
      name: r'loginNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loginNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LoginNotifier = AutoDisposeNotifier<LoginState>;
String _$loginFormNotifierHash() => r'eba7e8bddd8179a3693b7bedca08e287c3e82f96';

/// 登录表单状态管理器
///
/// 管理表单输入和验证
///
/// Copied from [LoginFormNotifier].
@ProviderFor(LoginFormNotifier)
final loginFormNotifierProvider =
    AutoDisposeNotifierProvider<LoginFormNotifier, LoginFormState>.internal(
      LoginFormNotifier.new,
      name: r'loginFormNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loginFormNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LoginFormNotifier = AutoDisposeNotifier<LoginFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
