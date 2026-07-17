import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';

/// 搜索常见问题用例。
class SearchFaqsUseCase {
  /// 构造函数。
  const SearchFaqsUseCase(this._repository);

  final FeedbackRepository _repository;

  /// 执行常见问题搜索。
  Future<Result<List<FaqItem>>> call(String query) {
    return _repository.searchFaqs(query.trim());
  }
}
