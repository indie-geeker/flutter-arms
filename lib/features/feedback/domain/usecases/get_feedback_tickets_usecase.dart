import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';

/// 获取反馈工单列表用例。
class GetFeedbackTicketsUseCase {
  /// 构造函数。
  const GetFeedbackTicketsUseCase(this._repository);

  final FeedbackRepository _repository;

  /// 获取反馈工单列表。
  Future<Result<List<FeedbackTicket>>> call() {
    return _repository.getTickets();
  }
}
