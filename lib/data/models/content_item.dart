import 'enums.dart';

class Episode {
  const Episode({
    required this.id,
    required this.title,
    required this.number,
    required this.season,
    required this.streamUrl,
    this.durationMinutes = 0,
  });

  final String id;
  final String title;
  final int number;
  final int season;
  final String streamUrl;
  final int durationMinutes;

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: '${json['id']}',
      title: (json['title'] as String?) ?? '',
      number: (json['number'] as num?)?.toInt() ?? 1,
      season: (json['season'] as num?)?.toInt() ?? 1,
      streamUrl: (json['stream_url'] as String?) ?? '',
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.posterUrl,
    required this.backdropUrl,
    required this.year,
    required this.rating,
    required this.durationMinutes,
    required this.genres,
    required this.description,
    required this.streamUrl,
    this.views = 0,
    this.episodes = const [],
  });

  final String id;
  final String title;
  final ContentType type;
  final String posterUrl;
  final String backdropUrl;
  final int year;
  final double rating;
  final int durationMinutes;
  final List<String> genres;
  final String description;
  final String streamUrl;
  final int views;
  final List<Episode> episodes;

  bool get hasEpisodes => episodes.isNotEmpty;

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final poster = (json['poster'] as String?) ?? '';
    return ContentItem(
      id: '${json['id']}',
      title: (json['title'] as String?) ?? '',
      type: ContentType.parse(json['type']),
      posterUrl: poster,
      backdropUrl: (json['backdrop'] as String?) ?? poster,
      year: (json['year'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      genres: ((json['genres'] as List?) ?? const [])
          .map((e) => '$e')
          .toList(growable: false),
      description: (json['description'] as String?) ?? '',
      streamUrl: (json['stream_url'] as String?) ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      episodes: ((json['episodes'] as List?) ?? const [])
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
