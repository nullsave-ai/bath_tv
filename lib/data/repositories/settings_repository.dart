import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kQuality = 'settings_quality';
  static const _kResume = 'settings_resume';
  static const _kReconnect = 'settings_reconnect';
  static const _kNotifications = 'settings_notifications';
  static const _kName = 'settings_display_name';
  static const _kDark = 'settings_dark_mode';

  AppSettings load() {
    return AppSettings(
      preferredQuality: _prefs.getInt(_kQuality) ?? 0,
      resumePlayback: _prefs.getBool(_kResume) ?? true,
      autoReconnect: _prefs.getBool(_kReconnect) ?? true,
      notifications: _prefs.getBool(_kNotifications) ?? true,
      displayName: _prefs.getString(_kName) ?? '',
      darkMode: _prefs.getBool(_kDark) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setInt(_kQuality, settings.preferredQuality);
    await _prefs.setBool(_kResume, settings.resumePlayback);
    await _prefs.setBool(_kReconnect, settings.autoReconnect);
    await _prefs.setBool(_kNotifications, settings.notifications);
    await _prefs.setString(_kName, settings.displayName);
    await _prefs.setBool(_kDark, settings.darkMode);
  }
}
