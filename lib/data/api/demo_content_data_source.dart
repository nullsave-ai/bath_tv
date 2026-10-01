import 'dart:math' as math;

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/arabic_normalizer.dart';
import '../models/channel.dart';
import '../models/content_item.dart';
import '../models/enums.dart';
import '../models/page_result.dart';
import 'content_data_source.dart';

/// مصدر بيانات تجريبي محلي (عناوين وقنوات افتراضية) يُستخدم عندما لا يُحدد
/// عنوان خادم. روابط HLS المستخدمة روابط اختبار عامة.
class DemoContentDataSource implements ContentDataSource {
  DemoContentDataSource() {
    _all = _buildContent();
    _channels = _buildChannels();
  }

  late final List<ContentItem> _all;
  late final List<Channel> _channels;

  static const _hlsSources = <String>[
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
  ];

  static const _titles = <String>[
    'ليالي بغداد',
    'صقر الصحراء',
    'أسرار المدينة',
    'رحلة إلى المجهول',
    'حكاية الوادي',
    'عاصفة الشمال',
    'ظلال الماضي',
    'بوابة الزمن',
    'نبض الأرض',
    'قلعة الأحلام',
    'سباق الأبطال',
    'طريق النجوم',
    'همس الرياح',
    'ساحر الجبال',
    'عودة الفارس',
    'بحر الأسرار',
    'وجوه المدينة',
    'ضوء في العتمة',
    'مفترق الطرق',
    'أيام الربيع',
  ];

  static const _parts = <String>[
    '',
    'الجزء الثاني',
    'الجزء الثالث',
    'الجزء الرابع',
    'الجزء الخامس',
  ];

  static const _genres = <String>[
    'أكشن',
    'دراما',
    'كوميديا',
    'خيال علمي',
    'رعب',
    'مغامرة',
    'رومانسي',
    'جريمة',
    'تاريخي',
    'فانتازيا',
  ];

  static const _descriptions = <String>[
    'قصة مشوقة تتصاعد أحداثها بين المفاجآت والتحديات، حيث يواجه أبطالها '
        'خيارات صعبة تغير مصيرهم إلى الأبد.',
    'رحلة مليئة بالإثارة والغموض تأخذ المشاهد إلى عوالم جديدة، وتكشف '
        'أسراراً ظلت مخفية لسنوات طويلة.',
    'حكاية إنسانية مؤثرة عن الصداقة والأمل، تجمع بين اللحظات الدافئة '
        'والمواقف الطريفة في عمل يناسب جميع أفراد العائلة.',
    'صراع محتدم بين الخير والشر في أجواء مشحونة بالتشويق، مع مشاهد '
        'بصرية آسرة وأداء لا يُنسى.',
  ];

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 350));

  static PageResult<T> _page<T>(List<T> all, int page) {
    final start = (page - 1) * AppConfig.pageSize;
    if (start >= all.length) return PageResult<T>(items: <T>[], hasMore: false);
    final end = math.min(start + AppConfig.pageSize, all.length);
    return PageResult<T>(
      items: all.sublist(start, end),
      hasMore: end < all.length,
    );
  }

  List<ContentItem> _byType(ContentType type) =>
      _all.where((e) => e.type == type).toList().reversed.toList();

  List<ContentItem> _sectionItems(HomeSection section) {
    switch (section) {
      case HomeSection.latest:
        return _all.reversed.toList();
      case HomeSection.popular:
        return [..._all]..sort((a, b) => b.views.compareTo(a.views));
      case HomeSection.movies:
        return _byType(ContentType.movie);
      case HomeSection.series:
        return _byType(ContentType.series);
      case HomeSection.anime:
        return _byType(ContentType.anime);
    }
  }

  @override
  Future<PageResult<ContentItem>> content({
    required HomeSection section,
    required int page,
  }) async {
    await _latency();
    return _page(_sectionItems(section), page);
  }

  @override
  Future<PageResult<ContentItem>> search({
    required String query,
    ContentType? type,
    required int page,
  }) async {
    await _latency();
    final q = normalizeArabic(query);
    final matches = _all.where((item) {
      if (type != null && item.type != type) return false;
      final haystack = normalizeArabic(
        '${item.title} ${item.genres.join(' ')} ${item.type.label}',
      );
      return haystack.contains(q);
    }).toList();
    return _page(matches, page);
  }

  @override
  Future<PageResult<Channel>> channels({
    required ChannelCategory category,
    required int page,
  }) async {
    await _latency();
    final list = category == ChannelCategory.all
        ? _channels
        : _channels.where((c) => c.category == category).toList();
    return _page(list, page);
  }

  @override
  Future<List<Channel>> searchChannels(String query) async {
    await _latency();
    final q = normalizeArabic(query);
    return _channels
        .where((c) =>
            normalizeArabic('${c.name} ${c.category.label}').contains(q))
        .toList(growable: false);
  }

  List<ContentItem> _buildContent() {
    final items = <ContentItem>[];
    for (var i = 0; i < 90; i++) {
      final type = ContentType.values[i % 3];
      final round = i ~/ _titles.length;
      final base = _titles[i % _titles.length];
      final title = round == 0 ? base : '$base ${_parts[round]}';
      final id = 'c$i';
      final isMovie = type == ContentType.movie;
      final genres = <String>{
        _genres[i % _genres.length],
        _genres[(i * 3 + 2) % _genres.length],
      }.toList();

      final episodes = <Episode>[];
      if (!isMovie) {
        final seasons = i % 4 == 0 ? 2 : 1;
        final perSeason = 6 + i % 7;
        for (var s = 1; s <= seasons; s++) {
          for (var n = 1; n <= perSeason; n++) {
            episodes.add(Episode(
              id: '${id}_s${s}e$n',
              title: '${AppStrings.episodeWord} $n',
              number: n,
              season: s,
              streamUrl: _hlsSources[(i + n) % _hlsSources.length],
              durationMinutes: 22 + (i + n) % 20,
            ));
          }
        }
      }

      items.add(ContentItem(
        id: id,
        title: title,
        type: type,
        posterUrl: 'https://picsum.photos/seed/bath-p$i/400/600',
        backdropUrl: 'https://picsum.photos/seed/bath-b$i/1280/720',
        year: 2012 + (i * 5) % 14,
        rating: 5.5 + ((i * 37) % 40) / 10,
        durationMinutes: isMovie ? 85 + (i * 11) % 60 : 24 + (i * 3) % 25,
        genres: genres,
        description: _descriptions[i % _descriptions.length],
        streamUrl: isMovie ? _hlsSources[i % _hlsSources.length] : '',
        views: (i * 7919) % 10007,
        episodes: episodes,
      ));
    }
    return items;
  }

  List<Channel> _buildChannels() {
    const byCategory = <ChannelCategory, List<String>>{
      ChannelCategory.sports: [
        'الملاعب الأولى',
        'رياضة بلس',
        'بطولات',
        'كرة اليوم',
        'الفروسية والسباق',
      ],
      ChannelCategory.news: [
        'الأخبار العاجلة',
        'نشرة اليوم',
        'العالم الآن',
        'اقتصاد وأسواق',
        'حوارات مفتوحة',
      ],
      ChannelCategory.entertainment: [
        'ترفيه ستار',
        'ضحك وسمر',
        'منوعات الليل',
        'ألحان',
        'برامج الواقع',
      ],
      ChannelCategory.kids: [
        'عالم الصغار',
        'كرتون كيدز',
        'مغامرات الأطفال',
        'تعلم ولعب',
      ],
      ChannelCategory.movies: [
        'سينما الأبطال',
        'أفلام كلاسيك',
        'سينما عالمية',
        'أكشن على مدار الساعة',
      ],
      ChannelCategory.series: [
        'دراما بلس',
        'مسلسلات اليوم',
        'حكايات',
        'دراما الخليج',
      ],
    };

    const programs = <ChannelCategory, List<String>>{
      ChannelCategory.sports: ['مباراة مباشرة', 'ملخص الجولة', 'تحليل المباراة'],
      ChannelCategory.news: ['نشرة الظهيرة', 'تقرير خاص', 'حوارات الساعة'],
      ChannelCategory.entertainment: ['سهرة المنوعات', 'ألحان الأمس', 'ضحك وسمر'],
      ChannelCategory.kids: ['مغامرات الصغار', 'ساعة الرسوم', 'ورشة المرح'],
      ChannelCategory.movies: ['فيلم الأمسية', 'عرض خاص', 'كلاسيكيات'],
      ChannelCategory.series: ['حلقة اليوم', 'إعادة الحلقة', 'الحكاية'],
    };

    final channels = <Channel>[];
    var index = 0;
    byCategory.forEach((category, names) {
      for (final name in names) {
        final list = programs[category]!;
        channels.add(Channel(
          programTitle: list[index % list.length],
          programProgress: (10 + (index * 37) % 80) / 100,
          id: 'ch$index',
          name: name,
          logoUrl: 'https://picsum.photos/seed/bath-c$index/240/240',
          category: category,
          streamUrl: _hlsSources[index % _hlsSources.length],
        ));
        index++;
      }
    });
    return channels;
  }
}
