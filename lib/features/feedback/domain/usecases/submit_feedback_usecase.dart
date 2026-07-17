import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';

/// 提交反馈用例。
class SubmitFeedbackUseCase {
  /// 构造函数。
  const SubmitFeedbackUseCase(this._repository);

  final FeedbackRepository _repository;

  /// 提交反馈。
  Future<Result<FeedbackTicket>> call(FeedbackDraft draft) {
    return _repository.submit(draft);
  }
}
