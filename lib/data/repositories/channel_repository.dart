import '../api/content_data_source.dart';
import '../models/channel.dart';
import '../models/enums.dart';
import '../models/page_result.dart';

class ChannelRepository {
  ChannelRepository(this._source);

  final ContentDataSource _source;
  final Map<String, PageResult<Channel>> _cache = {};

  Future<PageResult<Channel>> channels(
    ChannelCategory category,
    int page, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh && page == 1) {
      _cache.removeWhere((key, _) => key.startsWith('${category.name}|'));
    }
    final key = '${category.name}|$page';
    final cached = _cache[key];
    if (cached != null) return cached;
    final result = await _source.channels(category: category, page: page);
    _cache[key] = result;
    return result;
  }

  Future<List<Channel>> search(String query) => _source.searchChannels(query);

  void clearCache() => _cache.clear();
}
