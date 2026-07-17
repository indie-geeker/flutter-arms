import 'package:flutter_arms/features/feedback/data/models/faq_item_model.dart';
import 'package:flutter_arms/features/feedback/data/models/feedback_ticket_model.dart';
import 'package:flutter_arms/features/feedback/data/models/submit_feedback_request.dart';

/// 反馈远程数据源接口。
abstract interface class FeedbackRemoteDataSource {
  /// 搜索常见问题。
  Future<List<FaqItemModel>> searchFaqs(String query);

  /// 获取反馈工单列表。
  Future<List<FeedbackTicketModel>> getTickets();

  /// 获取指定反馈工单。
  Future<FeedbackTicketModel> getTicket(String id);

  /// 提交反馈。
  Future<FeedbackTicketModel> submit(SubmitFeedbackRequest request);
}
