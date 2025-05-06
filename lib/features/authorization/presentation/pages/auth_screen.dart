import 'dart:isolate';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authStateProvider);
    
    return Scaffold(
      // 设置为false，防止键盘弹出时自动调整布局
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: SafeArea(
        // 确保键盘弹出时内容可以滚动
        bottom: false, // 这里设置为false，因为我们使用Padding和BottomInset来处理底部安全区域
        child: loginState.when(
          data: (result) {
            if (result != null && result.isSuccess) {
              // 登录成功后的处理，可以延迟导航到首页
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.router.replaceNamed('/home');
              });
            }
            return _buildLoginForm(context);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '登录失败: ${error.toString()}', 
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authStateProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    // 获取键盘高度
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final topPadding = MediaQuery.of(context).padding.top;
    
    return GestureDetector(
      // 点击空白区域收起键盘
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        // 使用physics保持滚动的平滑性
        physics: const ClampingScrollPhysics(),
        // 根据键盘高度动态调整内容底部的padding
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
        child: Container(
          // 确保表单至少占满屏幕高度，避免内容过短时的布局跳跃
          height: screenHeight - appBarHeight - topPadding,
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部图标和文字
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 24),
                        Text(
                          '欢迎使用 ARMS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 36),
                
                // 用户名输入框
                TextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '请输入您的用户名',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                  // 下一步的行为处理
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    // 使用requestFocus减少布局计算
                    _passwordFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: 16),
                
                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入您的密码',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码长度不能少于6位';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _attemptLogin,
                ),
                const SizedBox(height: 8),
                
                // 记住我选项
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('记住我'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // 忘记密码处理
                      },
                      child: const Text('忘记密码?'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 登录按钮
                ElevatedButton(
                  onPressed: _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 注册选项 - 不再使用相对尺寸，避免布局变化
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('还没有账号?'),
                    TextButton(
                      onPressed: () {
                        // 导航到注册页面
                      },
                      child: const Text('立即注册'),
                    ),
                  ],
                ),
                
                // 使用Spacer代替固定高度的SizedBox
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _attemptLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus(); // 隐藏键盘
      
      // 执行登录操作
      ref.read(authStateProvider.notifier).login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      
      // 如果选择了记住我，可以在这里保存用户名
      if (_rememberMe) {
        // 实现保存用户名的逻辑
      }
    }
  }
}