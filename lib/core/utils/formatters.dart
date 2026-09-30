/// تنسيق الوقت بصيغة mm:ss أو h:mm:ss.
String formatDuration(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// تسمية الجودة للعرض.
String qualityLabel(int height) {
  if (height <= 0) return 'تلقائي';
  if (height >= 2160) return '4K (2160p)';
  if (height >= 1440) return '2K (1440p)';
  if (height >= 1080) return 'Full HD (1080p)';
  if (height >= 720) return 'HD (720p)';
  return '${height}p';
}
