import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_model.freezed.dart';
part 'token_model.g.dart';

/// Token 模型。
@freezed
abstract class TokenModel with _$TokenModel {
  /// 构造函数。
  const factory TokenModel({
    required String accessToken,
    required String refreshToken,
  }) = _TokenModel;

  /// JSON 反序列化。
  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);
}
