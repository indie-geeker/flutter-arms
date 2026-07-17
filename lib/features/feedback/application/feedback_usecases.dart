import 'package:flutter_arms/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_ticket_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_tickets_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/search_faqs_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_usecases.g.dart';

/// 常见问题搜索用例依赖注入。
@Riverpod(keepAlive: true)
SearchFaqsUseCase searchFaqsUseCase(Ref ref) {
  return SearchFaqsUseCase(ref.read(feedbackRepositoryProvider));
}

/// 反馈历史列表用例依赖注入。
@Riverpod(keepAlive: true)
GetFeedbackTicketsUseCase getFeedbackTicketsUseCase(Ref ref) {
  return GetFeedbackTicketsUseCase(ref.read(feedbackRepositoryProvider));
}

/// 反馈详情用例依赖注入。
@Riverpod(keepAlive: true)
GetFeedbackTicketUseCase getFeedbackTicketUseCase(Ref ref) {
  return GetFeedbackTicketUseCase(ref.read(feedbackRepositoryProvider));
}

/// 提交反馈用例依赖注入。
@Riverpod(keepAlive: true)
SubmitFeedbackUseCase submitFeedbackUseCase(Ref ref) {
  return SubmitFeedbackUseCase(ref.read(feedbackRepositoryProvider));
}
