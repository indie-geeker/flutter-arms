import 'package:meta/meta.dart';

/// 常见问题条目（Domain 层，纯 Dart）。
@immutable
final class FaqItem {
  /// 构造函数。
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  /// 条目 ID。
  final String id;

  /// 问题。
  final String question;

  /// 答案。
  final String answer;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FaqItem &&
        other.id == id &&
        other.question == question &&
        other.answer == answer;
  }

  @override
  int get hashCode => Object.hash(id, question, answer);
}
