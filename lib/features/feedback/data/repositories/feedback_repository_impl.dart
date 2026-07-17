import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:flutter_arms/features/feedback/data/datasources/retrofit_feedback_remote_datasource.dart';
import 'package:flutter_arms/features/feedback/data/models/faq_item_model.dart';
import 'package:flutter_arms/features/feedback/data/models/feedback_ticket_model.dart';
import 'package:flutter_arms/features/feedback/data/models/submit_feedback_request.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_repository_impl.g.dart';

/// 反馈仓储实现。
class FeedbackRepositoryImpl implements FeedbackRepository {
  /// 构造函数。
  const FeedbackRepositoryImpl(this._remote);

  final FeedbackRemoteDataSource _remote;

  @override
  Future<Result<List<FaqItem>>> searchFaqs(String query) async {
    try {
      final models = await _remote.searchFaqs(query);
      return Result.success(models.map((model) => model.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<List<FeedbackTicket>>> getTickets() async {
    try {
      final models = await _remote.getTickets();
      return Result.success(models.map((model) => model.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<FeedbackTicket>> getTicket(String id) async {
    try {
      final model = await _remote.getTicket(id);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<FeedbackTicket>> submit(FeedbackDraft draft) async {
    try {
      final request = SubmitFeedbackRequest.fromDomain(draft);
      final model = await _remote.submit(request);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}

/// 反馈仓储依赖注入。
@Riverpod(keepAlive: true)
FeedbackRepository feedbackRepository(Ref ref) {
  return FeedbackRepositoryImpl(ref.read(feedbackRemoteDataSourceProvider));
}
