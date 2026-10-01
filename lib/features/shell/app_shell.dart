import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/device_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/focusable.dart';
import '../../core/utils/math_utils.dart';
import '../../core/widgets/top_fade.dart';
import '../../providers/core_providers.dart';
import '../home/home_screen.dart';
import '../live/live_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

const _navItems = <NavBarItem>[
  NavBarItem(AppStrings.navHome, Icons.home_outlined, Icons.home),
  NavBarItem(AppStrings.navSearch, Icons.search, Icons.search),
  NavBarItem(
    AppStrings.navLive,
    Icons.live_tv_outlined,
    Icons.live_tv,
  ),
  NavBarItem(
    AppStrings.navSettings,
    Icons.settings_outlined,
    Icons.settings,
  ),
];

/// الهيكل الرئيسي: شريط تنقل عائم زجاجي وتدرج علوي ثابت للهاتف والتابلت،
/// وشريط علوي مخصص للتلفاز.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  static const _pages = <Widget>[
    HomeScreen(),
    SearchScreen(),
    LiveScreen(),
    SettingsScreen(),
  ];

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  double _dir = 1;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(navIndexProvider, (prev, next) {
      _dir = next > (prev ?? 0) ? 1 : -1;
      _anim.forward(from: 0);
    });
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final index = ref.watch(navIndexProvider);
    final select = ref.read(navIndexProvider.notifier);
    final tv = context.isTv;

    // كل الأقسام محفوظة الحالة، لكن يظهر قسم واحد فقط: القسم السابق يختفي فوراً
    // والجديد يدخل بتلاشي وانزلاق أفقي قصير، فلا تتراكم الصفحات فوق بعضها.
    final body = Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < _pages.length; i++)
          Offstage(
            offstage: i != index,
            child: TickerMode(
              enabled: i == index,
              child: ExcludeFocus(
                excluding: i != index,
                child: AnimatedBuilder(
                  animation: _curve,
                  child: _pages[i],
                  builder: (context, child) {
                    final v = i == index ? _curve.value : 1.0;
                    final dx = (1 - v) * 30 * _dir * (rtl ? -1 : 1);
                    return Opacity(
                      opacity: clampD(v, 0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      ),
                    );
                  },
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
          Icon(Icons.live_tv, color: AppColors.primary, size: 34),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          for (var i = 0; i < _navItems.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Focusable(
                onTap: () => onSelect(i),
                borderRadius: 12,
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected
                              ? _navItems[i].selectedIcon
                              : _navItems[i].icon,
                          size: 22,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _navItems[i].label,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
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
