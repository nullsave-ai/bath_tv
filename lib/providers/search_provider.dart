import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model_exports.dart';
import 'core_providers.dart';
import 'history_providers.dart';

enum SearchFilter {
  all('الكل', null),
  movies('أفلام', ContentType.movie),
  series('مسلسلات', ContentType.series),
  anime('أنمي', ContentType.anime),
  channels('القنوات', null);

  const SearchFilter(this.label, this.contentType);

  final String label;
  final ContentType? contentType;
}

class SearchState {
  SearchState({
    this.query = '',
    this.filter = SearchFilter.all,
    List<ContentItem>? content,
    List<Channel>? channels,
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = false,
    this.page = 1,
    this.error,
  })  : content = content ?? <ContentItem>[],
        channels = channels ?? <Channel>[];

  final String query;
  final SearchFilter filter;
  final List<ContentItem> content;
  final List<Channel> channels;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final int page;
  final Object? error;

  bool get isIdle => query.trim().isEmpty;
  bool get hasResults => content.isNotEmpty || channels.isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchFilter? filter,
    List<ContentItem>? content,
    List<Channel>? channels,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? page,
    Object? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      content: content ?? this.content,
      channels: channels ?? this.channels,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;
  int _token = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return SearchState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _token++;
      state = SearchState(filter: state.filter);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _run);
  }

  void setFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
    if (!state.isIdle) _run();
  }

  void submit() {
    _debounce?.cancel();
    final q = state.query.trim();
    if (q.isEmpty) return;
    ref.read(searchHistoryProvider.notifier).add(q);
    _run();
  }

  void remember() {
    ref.read(searchHistoryProvider.notifier).add(state.query);
  }

  Future<void> retry() => _run();

  Future<void> _run() async {
    final token = ++_token;
    final query = state.query.trim();
    final filter = state.filter;
    if (query.isEmpty) return;

    state = state.copyWith(
      loading: true,
      clearError: true,
      content: <ContentItem>[],
      channels: <Channel>[],
      hasMore: false,
      page: 1,
    );

    try {
      final contentFuture = filter == SearchFilter.channels
          ? Future<PageResult<ContentItem>>.value(
              PageResult<ContentItem>(items: <ContentItem>[], hasMore: false),
            )
          : ref.read(contentRepositoryProvider).search(
                query,
                type: filter.contentType,
                page: 1,
              );
      final channelsFuture =
          (filter == SearchFilter.all || filter == SearchFilter.channels)
              ? ref.read(channelRepositoryProvider).search(query)
              : Future<List<Channel>>.value(<Channel>[]);

      final results = await (contentFuture, channelsFuture).wait;
      if (token != _token) return;
      state = state.copyWith(
        loading: false,
        content: results.$1.items,
        channels: results.$2,
        hasMore: results.$1.hasMore,
        page: 1,
      );
    } catch (e) {
      if (token != _token) return;
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.loading ||
        state.loadingMore ||
        !state.hasMore ||
        state.filter == SearchFilter.channels) {
      return;
    }
    final token = _token;
    state = state.copyWith(loadingMore: true);
    try {
      final next = state.page + 1;
      final result = await ref.read(contentRepositoryProvider).search(
            state.query.trim(),
            type: state.filter.contentType,
            page: next,
          );
      if (token != _token) return;
      state = state.copyWith(
        content: [...state.content, ...result.items],
        hasMore: result.hasMore,
        page: next,
        loadingMore: false,
      );
    } catch (_) {
      if (token != _token) return;
      state = state.copyWith(loadingMore: false, hasMore: false);
    }
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
