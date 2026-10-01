import '../../core/constants/app_strings.dart';

enum ContentType {
  movie('movie', 'فيلم', AppStrings.movies),
  series('series', 'مسلسل', AppStrings.series),
  anime('anime', 'أنمي', AppStrings.anime);

  const ContentType(this.apiValue, this.label, this.pluralLabel);

  final String apiValue;
  final String label;
  final String pluralLabel;

  static ContentType parse(Object? value) {
    final v = '$value'.toLowerCase();
    return ContentType.values.firstWhere(
      (t) => t.apiValue == v,
      orElse: () => ContentType.movie,
    );
  }
}

enum HomeSection {
  latest('latest', AppStrings.latestAdditions),
  popular('popular', AppStrings.mostWatched),
  movies('movies', AppStrings.movies),
  series('series', AppStrings.series),
  anime('anime', AppStrings.anime);

  const HomeSection(this.apiValue, this.title);

  final String apiValue;
  final String title;
}

enum ChannelCategory {
  all('all', 'الكل'),
  sports('sports', 'الرياضة'),
  news('news', 'الأخبار'),
  entertainment('entertainment', 'الترفيه'),
  kids('kids', 'الأطفال'),
  movies('movies', 'الأفلام'),
  series('series', 'المسلسلات');

  const ChannelCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ChannelCategory parse(Object? value) {
    final v = '$value'.toLowerCase();
    return ChannelCategory.values.firstWhere(
      (c) => c.apiValue == v,
      orElse: () => ChannelCategory.entertainment,
    );
  }
}
