import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';

/// 获取反馈工单详情用例。
class GetFeedbackTicketUseCase {
  /// 构造函数。
  const GetFeedbackTicketUseCase(this._repository);

  final FeedbackRepository _repository;

  /// 获取指定反馈工单。
  Future<Result<FeedbackTicket>> call(String id) {
    return _repository.getTicket(id);
  }
}
