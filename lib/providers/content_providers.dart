import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model_exports.dart';
import 'core_providers.dart';
import 'paged_notifier.dart';

class ContentSectionNotifier extends PagedNotifier<ContentItem, HomeSection> {
  @override
  Future<PageResult<ContentItem>> fetchPage(
    int page, {
    bool forceRefresh = false,
  }) {
    return ref
        .read(contentRepositoryProvider)
        .section(arg, page, forceRefresh: forceRefresh);
  }
}

/// أقسام الشاشة الرئيسية، لكل قسم قائمة مقسمة إلى صفحات.
final contentSectionProvider = NotifierProvider.family<ContentSectionNotifier,
    PagedState<ContentItem>, HomeSection>(ContentSectionNotifier.new);

class ChannelsNotifier extends PagedNotifier<Channel, ChannelCategory> {
  @override
  Future<PageResult<Channel>> fetchPage(
    int page, {
    bool forceRefresh = false,
  }) {
    return ref
        .read(channelRepositoryProvider)
        .channels(arg, page, forceRefresh: forceRefresh);
  }
}

/// القنوات المباشرة حسب التصنيف.
final channelsProvider = NotifierProvider.family<ChannelsNotifier,
    PagedState<Channel>, ChannelCategory>(ChannelsNotifier.new);
