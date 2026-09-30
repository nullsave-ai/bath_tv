import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/device/device_profile.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';
import 'providers/settings_provider.dart';

/// جذر التطبيق: عربي فقط، واتجاه RTL أساسي، ووضعان ليلي ونهاري.
class BathApp extends ConsumerWidget {
  const BathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(settingsProvider.select((s) => s.darkMode));
    // يجب ضبط الألوان قبل بناء الثيم والواجهة.
    AppColors.dark = dark;

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.build(dark: dark, tv: DeviceProfile.isTelevision),
      themeAnimationDuration: Duration.zero,
      builder: (context, child) => _ThemeRefresher(
        dark: dark,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            systemNavigationBarIconBrightness:
                dark ? Brightness.light : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}

/// الألوان مقروءة من [AppColors] مباشرة، لذلك عند تبديل المظهر نعيد بناء
/// كل العناصر مرة واحدة مع الحفاظ على الحالة (التنقل والتمرير).
class _ThemeRefresher extends StatefulWidget {
  const _ThemeRefresher({required this.dark, required this.child});

  final bool dark;
  final Widget child;

  @override
  State<_ThemeRefresher> createState() => _ThemeRefresherState();
}

class _ThemeRefresherState extends State<_ThemeRefresher> {
  @override
  void didUpdateWidget(covariant _ThemeRefresher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dark != widget.dark) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _rebuildAll(context);
      });
    }
  }

  void _rebuildAll(BuildContext context) {
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
