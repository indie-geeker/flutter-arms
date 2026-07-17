import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/states/feedback_center_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_center_view_model.g.dart';

/// 反馈中心 ViewModel。
@riverpod
class FeedbackCenterViewModel extends _$FeedbackCenterViewModel {
  int _faqGeneration = 0;
  int _ticketGeneration = 0;
  int _activeRequests = 0;
  final _localTicketIds = <String>{};

  @override
  FeedbackCenterState build() => const FeedbackCenterState();

  /// 同时加载当前搜索词对应的常见问题与反馈历史。
  Future<void> load() async {
    final faqGeneration = ++_faqGeneration;
    final ticketGeneration = ++_ticketGeneration;
    final query = state.query;
    _activeRequests += 1;
    state = state.copyWith(
      isLoading: true,
      faqError: null,
      ticketError: null,
    );

    try {
      final faqRequest = ref.read(searchFaqsUseCaseProvider)(query);
      final ticketRequest = ref.read(getFeedbackTicketsUseCaseProvider)();
      await Future.wait<void>([
        _applyFaqResult(faqRequest, faqGeneration),
        _applyTicketResult(ticketRequest, ticketGeneration),
      ]);
    } finally {
      _finishRequest();
    }
  }

  /// 搜索常见问题，并保留已有反馈历史。
  Future<void> search(String query) async {
    final generation = ++_faqGeneration;
    _activeRequests += 1;
    state = state.copyWith(query: query, isLoading: true, faqError: null);

    try {
      final result = await ref.read(searchFaqsUseCaseProvider)(query);
      if (!ref.mounted) {
        return;
      }
      if (generation != _faqGeneration) {
        return;
      }

      switch (result) {
        case Success<List<FaqItem>>(:final data):
          state = state.copyWith(faqs: data, faqError: null);
        case FailureResult<List<FaqItem>>(:final failure):
          state = state.copyWith(faqError: failure);
      }
    } finally {
      _finishRequest();
    }
  }

  /// 重试当前查询对应的完整加载。
  Future<void> retry() => load();

  /// 将新提交的工单按 ID 去重后置顶。
  void addTicket(FeedbackTicket ticket) {
    _localTicketIds.add(ticket.id);
    state = state.copyWith(
      tickets: [
        ticket,
        ...state.tickets.where((item) => item.id != ticket.id),
      ],
    );
  }

  Future<void> _applyFaqResult(
    Future<Result<List<FaqItem>>> request,
    int generation,
  ) async {
    final result = await request;
    if (!ref.mounted || generation != _faqGeneration) {
      return;
    }

    switch (result) {
      case Success<List<FaqItem>>(:final data):
        state = state.copyWith(faqs: data, faqError: null);
      case FailureResult<List<FaqItem>>(:final failure):
        state = state.copyWith(faqError: failure);
    }
  }

  Future<void> _applyTicketResult(
    Future<Result<List<FeedbackTicket>>> request,
    int generation,
  ) async {
    final result = await request;
    if (!ref.mounted || generation != _ticketGeneration) {
      return;
    }

    switch (result) {
      case Success<List<FeedbackTicket>>(:final data):
        state = state.copyWith(
          tickets: _mergeServerTickets(data),
          ticketError: null,
        );
      case FailureResult<List<FeedbackTicket>>(:final failure):
        state = state.copyWith(ticketError: failure);
    }
  }

  List<FeedbackTicket> _mergeServerTickets(
    List<FeedbackTicket> serverTickets,
  ) {
    final serverIds = serverTickets.map((ticket) => ticket.id).toSet();
    _localTicketIds.removeAll(serverIds);
    final pendingLocalTickets = state.tickets.where(
      (ticket) => _localTicketIds.contains(ticket.id),
    );
    return [...pendingLocalTickets, ...serverTickets];
  }

  void _finishRequest() {
    assert(_activeRequests > 0, 'Request count must not underflow.');
    _activeRequests -= 1;
    if (!ref.mounted || _activeRequests > 0) {
      return;
    }
    state = state.copyWith(isLoading: false);
  }
}
