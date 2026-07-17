import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_center_state.freezed.dart';

/// 反馈中心页面状态。
@freezed
abstract class FeedbackCenterState with _$FeedbackCenterState {
  /// 构造函数。
  const factory FeedbackCenterState({
    @Default(<FaqItem>[]) List<FaqItem> faqs,
    @Default(<FeedbackTicket>[]) List<FeedbackTicket> tickets,
    @Default('') String query,
    @Default(false) bool isLoading,
    Failure? faqError,
    Failure? ticketError,
  }) = _FeedbackCenterState;

  const FeedbackCenterState._();

  /// 当前优先展示的错误，FAQ 错误优先于历史记录错误。
  Failure? get error => faqError ?? ticketError;
}
