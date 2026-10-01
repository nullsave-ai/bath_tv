import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../utils/math_utils.dart';

/// عنصر تفاعلي بفيزياء نوابض: يتقلص عند الضغط ويرتد عند الإفلات، ويكبر بنعومة
/// عند التركيز (ريموت)، مع بقعة ضوء تتبع موضع اللمس وبدون تأثير Material.
class Focusable extends StatefulWidget {
  const Focusable({
    super.key,
    required this.builder,
    this.onTap,
    this.autofocus = false,
    this.borderRadius = 12,
    this.focusNode,
    this.focusScale = 1.05,
    this.pressScale = 0.95,
    this.haptic = true,
    this.onFocusChange,
  });

  final Widget Function(BuildContext context, bool focused) builder;
  final VoidCallback? onTap;
  final bool autofocus;
  final double borderRadius;
  final FocusNode? focusNode;
  final double focusScale;
  final double pressScale;
  final bool haptic;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<Focusable> createState() => _FocusableState();
}

class _FocusableState extends State<Focusable> with TickerProviderStateMixin {
  static const _spring = SpringDescription(mass: 1, stiffness: 420, damping: 19);

  late final AnimationController _scale =
      AnimationController.unbounded(vsync: this, value: 1);
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 420),
  );

  bool _focused = false;
  bool _pressed = false;
  Offset _touch = Offset.zero;

  @override
  void dispose() {
    _scale.dispose();
    _glow.dispose();
    super.dispose();
  }

  void _settle() {
    final target =
        _pressed ? widget.pressScale : (_focused ? widget.focusScale : 1.0);
    _scale.animateWith(
      SpringSimulation(_spring, _scale.value, target, _scale.velocity),
    );
  }

  void _down(PointerDownEvent e) {
    if (widget.onTap == null) return;
    _touch = e.localPosition;
    _pressed = true;
    _glow.forward();
    _settle();
  }

  void _up() {
    if (!_pressed) return;
    _pressed = false;
    _glow.reverse();
    _settle();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      enabled: widget.onTap != null,
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) {
        if (_focused == value) return;
        setState(() => _focused = value);
        _settle();
      },
      onFocusChange: widget.onFocusChange,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: Listener(
        onPointerDown: _down,
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _up(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap == null
              ? null
              : () {
                  if (widget.haptic) HapticFeedback.selectionClick();
                  widget.onTap!();
                },
          child: AnimatedBuilder(
            animation: _scale,
            builder: (context, child) =>
                Transform.scale(scale: _scale.value, child: child),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: _focused
                      ? AppColors.focus.withAlpha(235)
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(150),
                          blurRadius: 26,
                          spreadRadius: 1,
                        ),
                      ]
                    : const [],
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  widget.builder(context, _focused),
                  if (widget.onTap != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            clampD(widget.borderRadius - 2, 0.0, 200.0),
                          ),
                          child: AnimatedBuilder(
                            animation: _glow,
                            builder: (context, _) => CustomPaint(
                              painter: _SpotPainter(
                                position: _touch,
                                t: Curves.easeOut.transform(_glow.value),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بقعة ضوء ناعمة تظهر تحت الإصبع عند اللمس.
class _SpotPainter extends CustomPainter {
  const _SpotPainter({required this.position, required this.t});

  final Offset position;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0.001) return;
    final radius = size.longestSide * 0.85 * (0.55 + 0.45 * t);
    final base = AppColors.dark ? Colors.white : AppColors.primary;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          base.withAlpha((AppColors.dark ? 52 : 46) * t ~/ 1),
          base.withAlpha(0),
        ],
      ).createShader(Rect.fromCircle(center: position, radius: radius));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SpotPainter old) => old.t != t || old.position != position;
}
