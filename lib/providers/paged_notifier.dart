import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model_exports.dart';

/// حالة قائمة مقسمة إلى صفحات (Pagination) مع حالات التحميل والخطأ.
class PagedState<T> {
  PagedState({
    List<T>? items,
    this.page = 0,
    this.hasMore = true,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  }) : items = items ?? <T>[];

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  bool get isInitialLoading => loading && items.isEmpty;

  PagedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return PagedState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// أساس مشترك لقوائم الصفحات: التحميل الأول، التحديث، وتحميل المزيد.
abstract class PagedNotifier<T, A> extends FamilyNotifier<PagedState<T>, A> {
  Future<PageResult<T>> fetchPage(int page, {bool forceRefresh = false});

  @override
  PagedState<T> build(A arg) {
    Future.microtask(refresh);
    return PagedState<T>(loading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await fetchPage(1, forceRefresh: true);
      state = PagedState<T>(
        items: result.items,
        page: 1,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.loading ||
        state.loadingMore ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final next = state.page + 1;
      final result = await fetchPage(next);
      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: next,
        hasMore: result.hasMore,
        loadingMore: false,
      );
    } catch (e) {
      // إيقاف المحاولات المتكررة عند الفشل؛ التحديث اليدوي يعيد الضبط.
      state = state.copyWith(loadingMore: false, hasMore: false, error: e);
    }
  }
}
