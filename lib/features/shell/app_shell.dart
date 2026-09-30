import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/device_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/focusable.dart';
import '../../core/widgets/status_bar_clouds.dart';
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

  /// موضع التمرير لكل قسم، ويحدد ظهور الغيوم.
  final List<double> _offsets = List<double>.filled(_pages.length, 0);
  final ValueNotifier<double> _scrollY = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollY.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n, int index) {
    if (n is ScrollUpdateNotification && n.metrics.axis == Axis.vertical) {
      final y = n.metrics.pixels;
      _offsets[index] = y;
      _scrollY.value = y;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navIndexProvider);
    final select = ref.read(navIndexProvider.notifier);
    final tv = context.isTv;

    ref.listen<int>(navIndexProvider, (_, next) {
      _scrollY.value = _offsets[next];
    });

    final body = NotificationListener<ScrollNotification>(
      onNotification: (n) => _onScroll(n, index),
      child: IndexedStack(
        index: index,
        children: [
          for (var i = 0; i < _pages.length; i++)
            TickerMode(
              enabled: i == index,
              child: ExcludeFocus(
                excluding: i != index,
                child: _pages[i],
              ),
            ),
        ],
      ),
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollY,
                builder: (context, y, _) =>
                    StatusBarClouds(intensity: (y / 48).clamp(0.0, 1.0)),
              ),
            ),
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
