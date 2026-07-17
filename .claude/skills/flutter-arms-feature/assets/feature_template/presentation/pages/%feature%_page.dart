import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/extensions/build_context_ext.dart';
import 'package:flutter_arms/features/%feature%/presentation/states/%feature%_state.dart';
import 'package:flutter_arms/features/%feature%/presentation/view_models/%feature%_view_model.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/dialogs/app_dialog.dart';
import 'package:flutter_arms/shared/widgets/empty_state_widget.dart';
import 'package:flutter_arms/shared/widgets/error_state_widget.dart';
import 'package:flutter_arms/shared/widgets/loading_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// %Feature% 页。
///
/// 使用 `ConsumerStatefulWidget` 是为了在 initState 里触发初始加载；
/// 若页面不需要首帧自动加载，可改为 `ConsumerWidget` 并由按钮/交互驱动。
@RoutePage()
class %Feature%Page extends ConsumerStatefulWidget {
  /// 构造函数。
  const %Feature%Page({super.key});

  @override
  ConsumerState<%Feature%Page> createState() => _%Feature%PageState();
}

class _%Feature%PageState extends ConsumerState<%Feature%Page> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(%feature%ViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    // 错误与跳转等副作用走 ref.listen，不触发 rebuild。
    ref.listen(%feature%ViewModelProvider, (previous, next) {
      final failure = next.error;
      if (failure != null && failure != previous?.error) {
        AppDialog.showError(context.failureMessage(failure));
      }
    });

    final state = ref.watch(%feature%ViewModelProvider);

    return Scaffold(
      // TODO(%feature%): 替换为真实标题 key。
      appBar: AppBar(title: Text(t.%feature%.title)),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(%feature%ViewModelProvider.notifier).load(),
        child: _%Feature%Body(state: state),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _%Feature%Body
// ---------------------------------------------------------------------------

class _%Feature%Body extends StatelessWidget {
  const _%Feature%Body({required this.state});

  final %Feature%State state;

  @override
  Widget build(BuildContext context) {
    // 首次加载：展示 loading。
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingWidget();
    }

    // 初始化失败且无缓存：展示整屏错误。
    if (state.error != null && state.items.isEmpty) {
      return ErrorStateWidget(
        message: context.failureMessage(state.error!),
      );
    }

    // 无数据：展示空态。
    if (state.items.isEmpty) {
      return const EmptyStateWidget();
    }

    // 正常列表。
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ListTile(
          title: Text(item.name),
          // TODO(%feature%): 替换为真实的 item 展示和点击跳转。
        );
      },
    );
  }
}
