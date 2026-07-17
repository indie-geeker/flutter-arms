import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/states/submit_feedback_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'submit_feedback_view_model.g.dart';

/// 提交反馈 ViewModel。
@riverpod
class SubmitFeedbackViewModel extends _$SubmitFeedbackViewModel {
  Future<Result<FeedbackTicket>>? _inFlight;

  @override
  SubmitFeedbackState build() => const SubmitFeedbackState();

  /// 更新反馈分类。
  void setCategory(FeedbackCategory category) {
    state = state.copyWith(category: category, error: null);
  }

  /// 更新反馈内容。
  void setMessage(String message) {
    state = state.copyWith(message: message, error: null);
  }

  /// 提交当前反馈；重复调用会复用正在进行的请求。
  Future<Result<FeedbackTicket>> submit() {
    final currentRequest = _inFlight;
    if (currentRequest != null) {
      return currentRequest;
    }

    final message = state.message.trim();
    if (message.isEmpty) {
      const failure = Failure(code: FailureCode.validation);
      state = state.copyWith(isSubmitting: false, error: failure);
      return Future<Result<FeedbackTicket>>.value(
        const Result<FeedbackTicket>.failure(failure),
      );
    }

    final draft = FeedbackDraft(category: state.category, message: message);
    state = state.copyWith(isSubmitting: true, error: null);
    late final Future<Result<FeedbackTicket>> request;
    request = _performSubmit(draft).whenComplete(() {
      if (identical(_inFlight, request)) {
        _inFlight = null;
      }
    });
    _inFlight = request;
    return request;
  }

  Future<Result<FeedbackTicket>> _performSubmit(FeedbackDraft draft) async {
    try {
      final result = await ref.read(submitFeedbackUseCaseProvider)(draft);
      if (ref.mounted) {
        switch (result) {
          case Success<FeedbackTicket>():
            state = state.copyWith(error: null);
          case FailureResult<FeedbackTicket>(:final failure):
            state = state.copyWith(error: failure);
        }
      }
      return result;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}
