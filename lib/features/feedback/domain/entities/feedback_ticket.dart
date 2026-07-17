import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:meta/meta.dart';

/// 反馈处理状态。
enum FeedbackStatus {
  /// 已提交。
  submitted,

  /// 处理中。
  reviewing,

  /// 已解决。
  resolved,

  /// 已关闭。
  closed,
}

/// 已提交的反馈工单（Domain 层，纯 Dart）。
@immutable
final class FeedbackTicket {
  /// 构造函数。
  const FeedbackTicket({
    required this.id,
    required this.category,
    required this.message,
    required this.status,
    required this.createdAt,
    this.reply,
  });

  /// 工单 ID。
  final String id;

  /// 反馈分类。
  final FeedbackCategory category;

  /// 反馈内容。
  final String message;

  /// 处理状态。
  final FeedbackStatus status;

  /// 创建时间。
  final DateTime createdAt;

  /// 客服回复。
  final String? reply;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FeedbackTicket &&
        other.id == id &&
        other.category == category &&
        other.message == message &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.reply == reply;
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    message,
    status,
    createdAt,
    reply,
  );
}
