import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../data/api/api_client.dart';
import '../data/api/content_data_source.dart';
import '../data/api/demo_content_data_source.dart';
import '../data/api/remote_content_data_source.dart';
import '../data/repositories/channel_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/settings_repository.dart';

/// يُستبدل في main() بالنسخة الحقيقية بعد التهيئة.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final contentDataSourceProvider = Provider<ContentDataSource>((ref) {
  if (AppConfig.useDemoData) return DemoContentDataSource();
  return RemoteContentDataSource(ApiClient(AppConfig.apiBaseUrl));
});

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(contentDataSourceProvider)),
);

final channelRepositoryProvider = Provider<ChannelRepository>(
  (ref) => ChannelRepository(ref.watch(contentDataSourceProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

/// القسم المحدد في شريط التنقل.
final navIndexProvider = StateProvider<int>((ref) => 0);

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);
