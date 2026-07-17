import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_ticket_model.freezed.dart';
part 'feedback_ticket_model.g.dart';

/// 反馈工单数据模型。
@freezed
abstract class FeedbackTicketModel with _$FeedbackTicketModel {
  /// 构造函数。
  const factory FeedbackTicketModel({
    required String id,
    required FeedbackCategory category,
    required String message,
    required FeedbackStatus status,
    required DateTime createdAt,
    String? reply,
  }) = _FeedbackTicketModel;

  /// JSON 反序列化。
  factory FeedbackTicketModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackTicketModelFromJson(json);
}

/// 反馈工单模型转换。
extension FeedbackTicketModelMapper on FeedbackTicketModel {
  /// 转换为领域实体。
  FeedbackTicket toEntity() {
    return FeedbackTicket(
      id: id,
      category: category,
      message: message,
      status: status,
      createdAt: createdAt,
      reply: reply,
    );
  }
}
