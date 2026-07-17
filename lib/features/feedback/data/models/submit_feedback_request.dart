import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_feedback_request.freezed.dart';
part 'submit_feedback_request.g.dart';

/// 提交反馈请求。
@freezed
abstract class SubmitFeedbackRequest with _$SubmitFeedbackRequest {
  /// 构造函数。
  const factory SubmitFeedbackRequest({
    required FeedbackCategory category,
    required String message,
  }) = _SubmitFeedbackRequest;

  /// 从领域草稿创建请求。
  factory SubmitFeedbackRequest.fromDomain(FeedbackDraft draft) {
    return SubmitFeedbackRequest(
      category: draft.category,
      message: draft.message,
    );
  }

  /// JSON 反序列化。
  factory SubmitFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitFeedbackRequestFromJson(json);
}
