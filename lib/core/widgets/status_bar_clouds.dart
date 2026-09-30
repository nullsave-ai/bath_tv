import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// غيوم تغطي شريط الإشعارات عند تمرير المحتوى أسفله.
///
/// طبقة ضبابية (blur) بحافة سحابية متعرجة مع نفخات ناعمة بألوان الهوية.
/// [intensity] بين 0 و1 وتحدد مدى ظهور الغيوم.
class StatusBarClouds extends StatelessWidget {
  const StatusBarClouds({super.key, required this.intensity});

  final double intensity;

  static const double _edge = 26;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final height = top + _edge + 14;

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: intensity.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 220),
        builder: (context, value, _) {
          if (value < 0.02) return const SizedBox.shrink();
          return SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipPath(
                  clipper: _CloudClipper(edge: _edge),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 2 + 20 * value,
                      sigmaY: 2 + 20 * value,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.background
                                .withAlpha((235 * value).round()),
                            AppColors.background
                                .withAlpha((150 * value).round()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: _CloudPuffPainter(
                    edge: _edge,
                    color: AppColors.cloud,
                    tint: AppColors.primary,
                    value: value,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// يقص حافة سفلية متعرجة على شكل سحابة.
class _CloudClipper extends CustomClipper<Path> {
  const _CloudClipper({required this.edge});

  final double edge;

  @override
  Path getClip(Size size) {
    final baseY = size.height - edge;
    const step = 54.0;
    final count = (size.width / step).ceil();
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, baseY);
    for (var i = 0; i < count; i++) {
      final x2 = size.width - (i + 1) * step;
      final mid = size.width - (i + 0.5) * step;
      final bump = edge * (0.55 + 0.45 * ((i * 7) % 5) / 4);
      path.quadraticBezierTo(mid, baseY + bump * 1.6, x2, baseY);
    }
    path
      ..lineTo(0, baseY)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_CloudClipper oldClipper) => oldClipper.edge != edge;
}

/// نفخات ناعمة تُرسم على طول حافة الغيوم.
class _CloudPuffPainter extends CustomPainter {
  const _CloudPuffPainter({
    required this.edge,
    required this.color,
    required this.tint,
    required this.value,
  });

  final double edge;
  final Color color;
  final Color tint;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height - edge;
    const step = 54.0;
    final count = (size.width / step).ceil();

    final white = Paint()
      ..color = color.withAlpha((color.alpha * value).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final tinted = Paint()
      ..color = tint.withAlpha((38 * value).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    for (var i = 0; i < count; i++) {
      final cx = size.width - (i + 0.5) * step;
      final radius = 15.0 + ((i * 5) % 4) * 4.5;
      canvas.drawCircle(Offset(cx, baseY + 2), radius + 6, tinted);
      canvas.drawCircle(Offset(cx, baseY - 2), radius, white);
    }
  }

  @override
  bool shouldRepaint(_CloudPuffPainter old) =>
      old.value != value || old.color != color || old.tint != tint;
}
