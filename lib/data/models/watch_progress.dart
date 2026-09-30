class WatchProgress {
  const WatchProgress({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.posterUrl,
    required this.streamUrl,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAtMs,
  });

  final String id;
  final String title;
  final String subtitle;
  final String posterUrl;
  final String streamUrl;
  final int positionMs;
  final int durationMs;
  final int updatedAtMs;

  double get fraction =>
      durationMs <= 0 ? 0 : (positionMs / durationMs).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'poster': posterUrl,
        'stream': streamUrl,
        'pos': positionMs,
        'dur': durationMs,
        'ts': updatedAtMs,
      };

  factory WatchProgress.fromJson(Map<String, dynamic> json) {
    return WatchProgress(
      id: '${json['id']}',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      posterUrl: (json['poster'] as String?) ?? '',
      streamUrl: (json['stream'] as String?) ?? '',
      positionMs: (json['pos'] as num?)?.toInt() ?? 0,
      durationMs: (json['dur'] as num?)?.toInt() ?? 0,
      updatedAtMs: (json['ts'] as num?)?.toInt() ?? 0,
    );
  }
}
