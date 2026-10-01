import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/watch_progress.dart';

/// يحفظ سجل البحث ومواضع المشاهدة محلياً.
class HistoryRepository {
  HistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kSearches = 'search_history';
  static const _kProgress = 'watch_progress';
  static const _maxSearches = 12;
  static const _maxProgress = 30;

  List<String> loadSearches() => _prefs.getStringList(_kSearches) ?? const [];

  Future<void> saveSearches(List<String> values) =>
      _prefs.setStringList(_kSearches, values.take(_maxSearches).toList());

  Map<String, WatchProgress> _readProgress() {
    final raw = _prefs.getString(_kProgress);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          WatchProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeProgress(Map<String, WatchProgress> map) {
    final encoded = jsonEncode(
      map.map((key, value) => MapEntry(key, value.toJson())),
    );
    return _prefs.setString(_kProgress, encoded);
  }

  List<WatchProgress> loadProgress() {
    final list = _readProgress().values.toList()
      ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return list;
  }

  Future<void> saveProgress(WatchProgress progress) async {
    final map = _readProgress();
    map[progress.id] = progress;
    if (map.length > _maxProgress) {
      final sorted = map.values.toList()
        ..sort((a, b) => a.updatedAtMs.compareTo(b.updatedAtMs));
      for (final old in sorted.take(map.length - _maxProgress)) {
        map.remove(old.id);
      }
    }
    await _writeProgress(map);
  }

  Future<void> removeProgress(String id) async {
    final map = _readProgress();
    if (map.remove(id) != null) await _writeProgress(map);
  }
}
