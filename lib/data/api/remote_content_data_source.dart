import '../../core/config/app_config.dart';
import '../models/channel.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../models/page_result.dart';
import 'api_client.dart';
import 'content_data_source.dart';

/// تنفيذ يتصل بخادم حقيقي. شكل الاستجابات موثق في README.md.
class RemoteContentDataSource implements ContentDataSource {
  RemoteContentDataSource(this._client);

  final ApiClient _client;

  @override
  Future<PageResult<ContentItem>> content({
    required HomeSection section,
    required int page,
  }) async {
    final json = await _client.getJson('/content', query: {
      'section': section.apiValue,
      'page': page,
      'page_size': AppConfig.pageSize,
    });
    return PageResult.fromJson(json, ContentItem.fromJson);
  }

  @override
  Future<PageResult<ContentItem>> search({
    required String query,
    ContentType? type,
    required int page,
  }) async {
    final json = await _client.getJson('/search', query: {
      'q': query,
      if (type != null) 'type': type.apiValue,
      'page': page,
      'page_size': AppConfig.pageSize,
    });
    return PageResult.fromJson(json, ContentItem.fromJson);
  }

  @override
  Future<PageResult<Channel>> channels({
    required ChannelCategory category,
    required int page,
  }) async {
    final json = await _client.getJson('/channels', query: {
      if (category != ChannelCategory.all) 'category': category.apiValue,
      'page': page,
      'page_size': AppConfig.pageSize,
    });
    return PageResult.fromJson(json, Channel.fromJson);
  }

  @override
  Future<List<Channel>> searchChannels(String query) async {
    final json = await _client.getJson('/channels/search', query: {'q': query});
    return ((json['items'] as List?) ?? const [])
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
