import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '%feature%_dto.freezed.dart';
part '%feature%_dto.g.dart';

/// %Feature% 数据传输对象（对应后端响应结构）。
@freezed
abstract class %Feature%Dto with _$%Feature%Dto {
  /// 构造函数。
  const factory %Feature%Dto({
    required String id,
    // TODO(%feature%): 替换为真实字段。字段名与后端 JSON 一致；
    // 若需要字段名转换，使用 @JsonKey(name: 'snake_case_name')。
    required String name,
  }) = _%Feature%Dto;

  /// JSON 反序列化。
  factory %Feature%Dto.fromJson(Map<String, dynamic> json) =>
      _$%Feature%DtoFromJson(json);
}

/// DTO → Entity 转换。
extension %Feature%DtoMapper on %Feature%Dto {
  /// 转换为领域实体。
  %Feature% toEntity() {
    return %Feature%(
      id: id,
      name: name,
    );
  }
}
