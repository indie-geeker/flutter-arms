// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 登录状态管理器
///
/// 使用 Riverpod annotation 定义状态管理

@ProviderFor(LoginNotifier)
const loginProvider = LoginNotifierProvider._();

/// 登录状态管理器
///
/// 使用 Riverpod annotation 定义状态管理
final class LoginNotifierProvider
    extends $NotifierProvider<LoginNotifier, LoginState> {
  /// 登录状态管理器
  ///
  /// 使用 Riverpod annotation 定义状态管理
  const LoginNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginNotifierHash();

  @$internal
  @override
  LoginNotifier create() => LoginNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginState>(value),
    );
  }
}

String _$loginNotifierHash() => r'0df2b03bd7d5e169ae49935f9e5aa729a4e2401a';

/// 登录状态管理器
///
/// 使用 Riverpod annotation 定义状态管理

abstract class _$LoginNotifier extends $Notifier<LoginState> {
  LoginState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LoginState, LoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginState, LoginState>,
              LoginState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 登录表单状态管理器
///
/// 管理表单输入和验证

@ProviderFor(LoginFormNotifier)
const loginFormProvider = LoginFormNotifierProvider._();

/// 登录表单状态管理器
///
/// 管理表单输入和验证
final class LoginFormNotifierProvider
    extends $NotifierProvider<LoginFormNotifier, LoginFormState> {
  /// 登录表单状态管理器
  ///
  /// 管理表单输入和验证
  const LoginFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginFormNotifierHash();

  @$internal
  @override
  LoginFormNotifier create() => LoginFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormState>(value),
    );
  }
}

String _$loginFormNotifierHash() => r'eba7e8bddd8179a3693b7bedca08e287c3e82f96';

/// 登录表单状态管理器
///
/// 管理表单输入和验证

abstract class _$LoginFormNotifier extends $Notifier<LoginFormState> {
  LoginFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormState, LoginFormState>,
              LoginFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
