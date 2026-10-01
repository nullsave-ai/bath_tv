import 'enums.dart';

class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.category,
    required this.streamUrl,
    this.programTitle = '',
    this.programProgress = 0,
  });

  final String id;
  final String name;
  final String logoUrl;
  final ChannelCategory category;
  final String streamUrl;

  /// البرنامج الجاري الآن ونسبة تقدمه (0 إلى 1)، اختياريان من الخادم.
  final String programTitle;
  final double programProgress;

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      logoUrl: (json['logo'] as String?) ?? '',
      category: ChannelCategory.parse(json['category']),
      streamUrl: (json['stream_url'] as String?) ?? '',
      programTitle: (json['now_title'] as String?) ?? '',
      programProgress: (json['now_progress'] as num?)?.toDouble() ?? 0,
    );
  }
}
