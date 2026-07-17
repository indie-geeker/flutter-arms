import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq_item_model.freezed.dart';
part 'faq_item_model.g.dart';

/// 常见问题数据模型。
@freezed
abstract class FaqItemModel with _$FaqItemModel {
  /// 构造函数。
  const factory FaqItemModel({
    required String id,
    required String question,
    required String answer,
  }) = _FaqItemModel;

  /// JSON 反序列化。
  factory FaqItemModel.fromJson(Map<String, dynamic> json) =>
      _$FaqItemModelFromJson(json);
}

/// 常见问题模型转换。
extension FaqItemModelMapper on FaqItemModel {
  /// 转换为领域实体。
  FaqItem toEntity() {
    return FaqItem(id: id, question: question, answer: answer);
  }
}
