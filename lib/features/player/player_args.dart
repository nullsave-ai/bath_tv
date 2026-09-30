import '../../data/model_exports.dart';

/// معطيات فتح المشغل (فيلم/حلقة أو قناة مباشرة).
class PlayerArgs {
  const PlayerArgs({
    required this.id,
    required this.title,
    required this.streamUrl,
    this.subtitle = '',
    this.posterUrl = '',
    this.isLive = false,
    this.startPosition = Duration.zero,
    this.channels = const [],
    this.channelIndex = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String posterUrl;
  final String streamUrl;
  final bool isLive;
  final Duration startPosition;

  /// قائمة القنوات للتنقل بين القنوات أثناء البث المباشر.
  final List<Channel> channels;
  final int channelIndex;
}
