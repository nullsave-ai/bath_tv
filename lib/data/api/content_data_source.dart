import '../models/channel.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../models/page_result.dart';

/// واجهة مصدر البيانات. لها تنفيذان: خادم حقيقي، وبيانات تجريبية محلية.
abstract class ContentDataSource {
  Future<PageResult<ContentItem>> content({
    required HomeSection section,
    required int page,
  });

  Future<PageResult<ContentItem>> search({
    required String query,
    ContentType? type,
    required int page,
  });

  Future<PageResult<Channel>> channels({
    required ChannelCategory category,
    required int page,
  });

  Future<List<Channel>> searchChannels(String query);
}
