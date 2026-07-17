import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:flutter_arms/features/feedback/data/models/faq_item_model.dart';
import 'package:flutter_arms/features/feedback/data/models/feedback_ticket_model.dart';
import 'package:flutter_arms/features/feedback/data/models/submit_feedback_request.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'retrofit_feedback_remote_datasource.g.dart';

/// Retrofit 反馈 API。
@RestApi()
abstract class RetrofitFeedbackApi {
  /// 构造函数。
  factory RetrofitFeedbackApi(Dio dio, {String baseUrl}) = _RetrofitFeedbackApi;

  /// 搜索常见问题。
  @GET('/feedback/faqs')
  Future<List<FaqItemModel>> searchFaqs(@Query('q') String query);

  /// 获取反馈工单列表。
  @GET('/feedback')
  Future<List<FeedbackTicketModel>> getTickets();

  /// 获取指定反馈工单。
  @GET('/feedback/{id}')
  Future<FeedbackTicketModel> getTicket(@Path('id') String id);

  /// 提交反馈。
  @POST('/feedback')
  Future<FeedbackTicketModel> submit(@Body() SubmitFeedbackRequest request);
}

/// Retrofit 反馈远程数据源。
final class RetrofitFeedbackRemoteDataSource
    implements FeedbackRemoteDataSource {
  /// 构造函数。
  const RetrofitFeedbackRemoteDataSource(this._api);

  final RetrofitFeedbackApi _api;

  @override
  Future<List<FaqItemModel>> searchFaqs(String query) {
    return _api.searchFaqs(query).asApi();
  }

  @override
  Future<List<FeedbackTicketModel>> getTickets() {
    return _api.getTickets().asApi();
  }

  @override
  Future<FeedbackTicketModel> getTicket(String id) {
    return _api.getTicket(id).asApi();
  }

  @override
  Future<FeedbackTicketModel> submit(SubmitFeedbackRequest request) {
    return _api.submit(request).asApi();
  }
}

/// 默认反馈远程数据源。
@Riverpod(keepAlive: true)
FeedbackRemoteDataSource feedbackRemoteDataSource(Ref ref) {
  return RetrofitFeedbackRemoteDataSource(
    RetrofitFeedbackApi(ref.read(dioProvider)),
  );
}
