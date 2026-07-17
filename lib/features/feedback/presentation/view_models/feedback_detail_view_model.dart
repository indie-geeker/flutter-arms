import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/states/feedback_detail_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_detail_view_model.g.dart';

/// 反馈详情 ViewModel。
@riverpod
class FeedbackDetailViewModel extends _$FeedbackDetailViewModel {
  int _requestGeneration = 0;

  @override
  FeedbackDetailState build(String ticketId) => const FeedbackDetailState();

  /// 加载当前工单详情。
  Future<void> load() async {
    final generation = ++_requestGeneration;
    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(getFeedbackTicketUseCaseProvider)(ticketId);
    if (!ref.mounted || generation != _requestGeneration) {
      return;
    }

    switch (result) {
      case Success<FeedbackTicket>(:final data):
        state = state.copyWith(
          ticket: data,
          isLoading: false,
          error: null,
        );
      case FailureResult<FeedbackTicket>(:final failure):
        state = state.copyWith(isLoading: false, error: failure);
    }
  }

  /// 重试加载当前工单详情。
  Future<void> retry() => load();
}
