import 'enums.dart';

class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.category,
    required this.streamUrl,
  });

  final String id;
  final String name;
  final String logoUrl;
  final ChannelCategory category;
  final String streamUrl;

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      logoUrl: (json['logo'] as String?) ?? '',
      category: ChannelCategory.parse(json['category']),
      streamUrl: (json['stream_url'] as String?) ?? '',
    );
  }
}
