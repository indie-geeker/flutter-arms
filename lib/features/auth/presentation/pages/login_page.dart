import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter_arms/i18n/strings.g.dart';

/// 登录页。
@RoutePage()
class LoginPage extends StatelessWidget {
  /// 构造函数。
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      appBar: AppBar(title: Text(t.auth.title)),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _LoginHeader(),
              SizedBox(height: 24),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.t.auth.welcomeBack,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    );
  }
}
