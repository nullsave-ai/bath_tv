import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/focusable.dart';
import '../../providers/core_providers.dart';
import '../../providers/settings_provider.dart';
import '../common/navigation.dart';
import 'privacy_policy_screen.dart';
import '../../core/widgets/floating_nav_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _qualityOptions = <int>[0, 2160, 1080, 720, 480, 360];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = UiMetrics.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final version = ref.watch(packageInfoProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            m.pagePadding,
            16 + MediaQuery.paddingOf(context).top,
            m.pagePadding,
            40 + navReserve(context),
          ),
          children: [
            Text(
              AppStrings.navSettings,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const _Label(AppStrings.settingsAccount),
            _Tile(
              icon: Icons.person_rounded,
              title: settings.displayName.isEmpty
                  ? AppStrings.guest
                  : settings.displayName,
              subtitle: AppStrings.accountSubtitle,
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _editAccount(context, ref),
            ),
            const _Label(AppStrings.settingsAppearance),
            _Tile(
              icon: settings.darkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              title: AppStrings.darkMode,
              subtitle: AppStrings.darkModeSub,
              trailing: _SwitchIndicator(value: settings.darkMode),
              onTap: () =>
                  notifier.update((s) => s.copyWith(darkMode: !s.darkMode)),
            ),
            const _Label(AppStrings.settingsPlayback),
            _Tile(
              icon: Icons.hd_rounded,
              title: AppStrings.videoQuality,
              subtitle: settings.isAutoQuality
                  ? AppStrings.qualityAutoRecommended
                  : qualityLabel(settings.preferredQuality),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _pickQuality(context, ref),
            ),
            _Tile(
              icon: Icons.restore_rounded,
              title: AppStrings.resumePlayback,
              subtitle: AppStrings.resumePlaybackSub,
              trailing: _SwitchIndicator(value: settings.resumePlayback),
              onTap: () => notifier.update(
                (s) => s.copyWith(resumePlayback: !s.resumePlayback),
              ),
            ),
            _Tile(
              icon: Icons.sync_rounded,
              title: AppStrings.autoReconnect,
              subtitle: AppStrings.autoReconnectSub,
              trailing: _SwitchIndicator(value: settings.autoReconnect),
              onTap: () => notifier.update(
                (s) => s.copyWith(autoReconnect: !s.autoReconnect),
              ),
            ),
            const _Label(AppStrings.settingsNotifications),
            _Tile(
              icon: Icons.notifications_rounded,
              title: AppStrings.notificationsToggle,
              subtitle: AppStrings.notificationsSub,
              trailing: _SwitchIndicator(value: settings.notifications),
              onTap: () => notifier.update(
                (s) => s.copyWith(notifications: !s.notifications),
              ),
            ),
            const _Label(AppStrings.settingsStorage),
            _Tile(
              icon: Icons.cleaning_services_rounded,
              title: AppStrings.clearCache,
              subtitle: AppStrings.clearCacheSub,
              onTap: () => _clearCache(context, ref),
            ),
            const _Label(AppStrings.settingsAbout),
            _Tile(
              icon: Icons.info_rounded,
              title: AppStrings.aboutApp,
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _showAbout(context),
            ),
            _Tile(
              icon: Icons.privacy_tip_rounded,
              title: AppStrings.privacyPolicy,
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.of(context).push(
                smoothRoute<void>(const PrivacyPolicyScreen()),
              ),
            ),
            _Tile(
              icon: Icons.tag_rounded,
              title: AppStrings.appVersion,
              subtitle: version.maybeWhen(
                data: (info) => '${info.version} (${info.buildNumber})',
                orElse: () => '-',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editAccount(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsProvider).displayName;
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.settingsAccount),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: AppStrings.accountName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text(AppStrings.signOut),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(displayName: result));
  }

  Future<void> _pickQuality(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsProvider).preferredQuality;
    final choice = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(AppStrings.videoQuality),
        children: [
          for (final q in _qualityOptions)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, q),
              child: Row(
                children: [
                  Icon(
                    q == current
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: q == current
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(q == 0
                      ? AppStrings.qualityAutoRecommended
                      : qualityLabel(q)),
                ],
              ),
            ),
        ],
      ),
    );
    if (choice == null) return;
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(preferredQuality: choice));
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    await DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    ref.read(contentRepositoryProvider).clearCache();
    ref.read(channelRepositoryProvider).clearCache();
    if (context.mounted) showMessage(context, AppStrings.cacheCleared);
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.aboutApp),
        content: const Text(AppStrings.aboutBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.accentText,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap == null) return content;
    return Focusable(
      onTap: onTap,
      borderRadius: 14,
      focusScale: 1.02,
      builder: (context, focused) => content,
    );
  }
}

/// مؤشر تبديل بصري؛ الضغط يتم على البطاقة كاملة (ملائم للريموت واللمس).
class _SwitchIndicator extends StatelessWidget {
  const _SwitchIndicator({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: IgnorePointer(
        child: Switch(value: value, onChanged: (_) {}),
      ),
    );
  }
}
