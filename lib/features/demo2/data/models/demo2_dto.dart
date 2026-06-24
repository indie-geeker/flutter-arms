import 'package:freezed_annotation/freezed_annotation.dart';

part 'demo2_dto.freezed.dart';
part 'demo2_dto.g.dart';

@freezed
class Demo2Dto with _$Demo2Dto {
  const factory Demo2Dto({
    required String id,
  }) = _Demo2Dto;

  factory Demo2Dto.fromJson(Map<String, dynamic> json) => _$Demo2DtoFromJson(json);
}
