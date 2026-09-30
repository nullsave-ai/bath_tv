import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// خلفية التطبيق: تدرج هادئ مع توهجات بألوان الهوية تظهر خلف الزجاج.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.background,
                  Color.alphaBlend(
                    AppColors.primary.withAlpha(AppColors.dark ? 28 : 22),
                    AppColors.background,
                  ),
                  AppColors.background,
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: -140,
            end: -120,
            child: _Glow(color: AppColors.primary, size: 420, alpha: 70),
          ),
          PositionedDirectional(
            bottom: -160,
            start: -140,
            child: _Glow(color: AppColors.accent, size: 420, alpha: 34),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size, required this.alpha});

  final Color color;
  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withAlpha(alpha), color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}
