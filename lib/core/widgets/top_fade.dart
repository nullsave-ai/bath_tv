import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// تدرج أسود شفاف ثابت أعلى الشاشة خلف شريط الإشعارات والأدوات:
/// أغمق عند الحافة العليا ويتلاشى تدريجياً للأسفل. لا يتأثر بالتمرير.
class TopFade extends StatelessWidget {
  const TopFade({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final dark = AppColors.dark;
    return IgnorePointer(
      child: Container(
        height: top + 84,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(dark ? 150 : 70),
              Colors.black.withAlpha(dark ? 64 : 26),
              Colors.black.withAlpha(dark ? 18 : 6),
              Colors.black.withAlpha(0),
            ],
            stops: const [0.0, 0.38, 0.72, 1.0],
          ),
        ),
      ),
    );
  }
}
