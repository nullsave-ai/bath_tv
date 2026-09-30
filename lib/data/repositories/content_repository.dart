import '../api/content_data_source.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../models/page_result.dart';

/// مستودع المحتوى: يفصل الواجهة عن مصدر البيانات ويضيف تخزيناً مؤقتاً للصفحات.
class ContentRepository {
  ContentRepository(this._source);

  final ContentDataSource _source;
  final Map<String, PageResult<ContentItem>> _cache = {};

  Future<PageResult<ContentItem>> section(
    HomeSection section,
    int page, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh && page == 1) {
      _cache.removeWhere((key, _) => key.startsWith('${section.name}|'));
    }
    final key = '${section.name}|$page';
    final cached = _cache[key];
    if (cached != null) return cached;
    final result = await _source.content(section: section, page: page);
    _cache[key] = result;
    return result;
  }

  Future<PageResult<ContentItem>> search(
    String query, {
    ContentType? type,
    int page = 1,
  }) {
    return _source.search(query: query, type: type, page: page);
  }

  void clearCache() => _cache.clear();
}
