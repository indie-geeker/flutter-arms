import 'package:meta/meta.dart';

/// 反馈分类。
enum FeedbackCategory {
  /// 缺陷反馈。
  bug,

  /// 功能建议。
  suggestion,

  /// 其他反馈。
  other,
}

/// 待提交的反馈（Domain 层，纯 Dart）。
@immutable
final class FeedbackDraft {
  /// 构造函数。
  const FeedbackDraft({required this.category, required this.message});

  /// 反馈分类。
  final FeedbackCategory category;

  /// 反馈内容。
  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FeedbackDraft &&
        other.category == category &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(category, message);
}
