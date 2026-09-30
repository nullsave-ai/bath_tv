import '../../core/config/app_config.dart';

class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final items = ((json['items'] as List?) ?? const [])
        .map((e) => parse(e as Map<String, dynamic>))
        .toList(growable: false);
    final hasMore = json['has_more'] as bool? ?? items.length >= AppConfig.pageSize;
    return PageResult<T>(items: items, hasMore: hasMore);
  }
}
