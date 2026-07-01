// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_usecases.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 登录用例依赖注入。

@ProviderFor(loginUseCase)
const loginUseCaseProvider = LoginUseCaseProvider._();

/// 登录用例依赖注入。

final class LoginUseCaseProvider
    extends $FunctionalProvider<LoginUseCase, LoginUseCase, LoginUseCase>
    with $Provider<LoginUseCase> {
  /// 登录用例依赖注入。
  const LoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUseCase create(Ref ref) {
    return loginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUseCase>(value),
    );
  }
}

String _$loginUseCaseHash() => r'b58f178c597e498bf4583d45fed68194ec6564e3';

/// 登出用例依赖注入。

@ProviderFor(logoutUseCase)
const logoutUseCaseProvider = LogoutUseCaseProvider._();

/// 登出用例依赖注入。

final class LogoutUseCaseProvider
    extends $FunctionalProvider<LogoutUseCase, LogoutUseCase, LogoutUseCase>
    with $Provider<LogoutUseCase> {
  /// 登出用例依赖注入。
  const LogoutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutUseCaseHash();

  @$internal
  @override
  $ProviderElement<LogoutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutUseCase create(Ref ref) {
    return logoutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutUseCase>(value),
    );
  }
}

String _$logoutUseCaseHash() => r'8dabff497d43ce73ee573935c6222a93cefbf70f';

/// 刷新 Token 用例依赖注入。
///
/// 当前 UI 未直接消费（刷新由 `TokenInterceptor` 自动处理），
/// 保留用例以供未来业务主动刷新场景与单元测试复用。

@ProviderFor(refreshTokenUseCase)
const refreshTokenUseCaseProvider = RefreshTokenUseCaseProvider._();

/// 刷新 Token 用例依赖注入。
///
/// 当前 UI 未直接消费（刷新由 `TokenInterceptor` 自动处理），
/// 保留用例以供未来业务主动刷新场景与单元测试复用。

final class RefreshTokenUseCaseProvider
    extends
        $FunctionalProvider<
          RefreshTokenUseCase,
          RefreshTokenUseCase,
          RefreshTokenUseCase
        >
    with $Provider<RefreshTokenUseCase> {
  /// 刷新 Token 用例依赖注入。
  ///
  /// 当前 UI 未直接消费（刷新由 `TokenInterceptor` 自动处理），
  /// 保留用例以供未来业务主动刷新场景与单元测试复用。
  const RefreshTokenUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshTokenUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshTokenUseCaseHash();

  @$internal
  @override
  $ProviderElement<RefreshTokenUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshTokenUseCase create(Ref ref) {
    return refreshTokenUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshTokenUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshTokenUseCase>(value),
    );
  }
}

String _$refreshTokenUseCaseHash() =>
    r'783c7c9888c5727b787c0e1f2945bc75e28ce650';
