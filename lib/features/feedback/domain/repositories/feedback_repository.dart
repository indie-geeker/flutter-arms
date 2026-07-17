import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';

/// 反馈仓储接口。
abstract class FeedbackRepository {
  /// 搜索常见问题。
  Future<Result<List<FaqItem>>> searchFaqs(String query);

  /// 获取反馈工单列表。
  Future<Result<List<FeedbackTicket>>> getTickets();

  /// 获取指定反馈工单。
  Future<Result<FeedbackTicket>> getTicket(String id);

  /// 提交反馈。
  Future<Result<FeedbackTicket>> submit(FeedbackDraft draft);
}
