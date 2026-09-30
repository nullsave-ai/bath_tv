import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model_exports.dart';
import 'core_providers.dart';

/// مواضع المشاهدة المحفوظة (متابعة المشاهدة).
class ContinueWatchingNotifier extends Notifier<List<WatchProgress>> {
  @override
  List<WatchProgress> build() =>
      ref.read(historyRepositoryProvider).loadProgress();

  Future<void> save(WatchProgress progress) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.saveProgress(progress);
    state = repo.loadProgress();
  }

  Future<void> remove(String id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.removeProgress(id);
    state = repo.loadProgress();
  }

  WatchProgress? byId(String id) {
    for (final p in state) {
      if (p.id == id) return p;
    }
    return null;
  }
}

final continueWatchingProvider =
    NotifierProvider<ContinueWatchingNotifier, List<WatchProgress>>(
  ContinueWatchingNotifier.new,
);

/// سجل عمليات البحث.
class SearchHistoryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(historyRepositoryProvider).loadSearches();

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [q, ...state.where((e) => e != q)].take(12).toList();
    state = updated;
    await ref.read(historyRepositoryProvider).saveSearches(updated);
  }

  Future<void> clear() async {
    state = <String>[];
    await ref.read(historyRepositoryProvider).saveSearches(<String>[]);
  }
}

final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<String>>(
  SearchHistoryNotifier.new,
);
