class AppSettings {
  const AppSettings({
    this.preferredQuality = 0,
    this.resumePlayback = true,
    this.autoReconnect = true,
    this.notifications = true,
    this.displayName = '',
    this.darkMode = true,
  });

  /// 0 = تلقائي، وإلا الارتفاع المفضل بالبكسل (360، 480، 720، 1080، 2160).
  final int preferredQuality;
  final bool resumePlayback;
  final bool autoReconnect;
  final bool notifications;
  final String displayName;
  final bool darkMode;

  bool get isAutoQuality => preferredQuality == 0;

  AppSettings copyWith({
    int? preferredQuality,
    bool? resumePlayback,
    bool? autoReconnect,
    bool? notifications,
    String? displayName,
    bool? darkMode,
  }) {
    return AppSettings(
      preferredQuality: preferredQuality ?? this.preferredQuality,
      resumePlayback: resumePlayback ?? this.resumePlayback,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      notifications: notifications ?? this.notifications,
      displayName: displayName ?? this.displayName,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
