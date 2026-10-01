import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/device_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/focusable.dart';
import '../../core/widgets/top_fade.dart';
import '../../providers/core_providers.dart';
import '../home/home_screen.dart';
import '../live/live_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

const _navItems = <NavBarItem>[
  NavBarItem(AppStrings.navHome, Icons.home_outlined, Icons.home_rounded),
  NavBarItem(AppStrings.navSearch, Icons.search_rounded, Icons.search_rounded),
  NavBarItem(
    AppStrings.navLive,
    Icons.live_tv_outlined,
    Icons.live_tv_rounded,
  ),
  NavBarItem(
    AppStrings.navSettings,
    Icons.settings_outlined,
    Icons.settings_rounded,
  ),
];

/// الهيكل الرئيسي: شريط تنقل عائم زجاجي وغيوم علوية للهاتف والتابلت،
/// وشريط علوي مخصص للتلفاز.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _pages = <Widget>[
    HomeScreen(),
    SearchScreen(),
    LiveScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navIndexProvider);
    final select = ref.read(navIndexProvider.notifier);
    final tv = context.isTv;

    // كل الأقسام محفوظة الحالة، والتبديل بينها بتلاشي وانزلاق ناعمين.
    final body = Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < _pages.length; i++)
          TickerMode(
            enabled: i == index,
            child: ExcludeFocus(
              excluding: i != index,
              child: IgnorePointer(
                ignoring: i != index,
                child: AnimatedOpacity(
                  opacity: i == index ? 1 : 0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSlide(
                    offset: i == index ? Offset.zero : const Offset(0, 0.025),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutQuart,
                    child: _pages[i],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final Widget content;
    if (tv) {
      content = Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _TvTopBar(index: index, onSelect: (i) => select.state = i),
              Expanded(child: body),
            ],
          ),
        ),
      );
    } else {
      content = Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: body),
            const Positioned(top: 0, left: 0, right: 0, child: TopFade()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBar(
                items: _navItems,
                index: index,
                onSelect: (i) => select.state = i,
              ),
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) select.state = 0;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [const AppBackground(), content],
      ),
    );
  }
}

class _TvTopBar extends StatelessWidget {
  const _TvTopBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 14, 48, 6),
      child: Row(
        children: [
          Icon(Icons.live_tv_rounded, color: AppColors.primary, size: 34),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          for (var i = 0; i < _navItems.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Focusable(
                onTap: () => onSelect(i),
                borderRadius: 30,
                focusScale: 1.06,
                builder: (context, focused) {
                  final selected = i == index;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withAlpha(90)
                          : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected
                              ? _navItems[i].selectedIcon
                              : _navItems[i].icon,
                          size: 26,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _navItems[i].label,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
