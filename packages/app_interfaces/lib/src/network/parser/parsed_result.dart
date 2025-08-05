
import '../models/api_response.dart';

class ParsedResult<T>{
  final ApiResponse<T> apiResponse;
  final bool isSuccess;

  ParsedResult({
    required this.apiResponse,
    required this.isSuccess
});
}