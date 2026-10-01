import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// عنصر تفاعلي بفيزياء نوابض: يتقلص عند الضغط ويرتد عند الإفلات، ويكبر بنعومة
/// عند التركيز (ريموت). خفيف عمداً: متحكم واحد، وبلا رسم إضافي إلا عند التركيز.
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

class _FocusableState extends State<Focusable>
    with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(mass: 1, stiffness: 420, damping: 19);

  late final AnimationController _scale =
      AnimationController.unbounded(vsync: this, value: 1);

  bool _focused = false;
  bool _pressed = false;

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _settle() {
    final target =
        _pressed ? widget.pressScale : (_focused ? widget.focusScale : 1.0);
    _scale.animateWith(
      SpringSimulation(_spring, _scale.value, target, _scale.velocity),
    );
  }

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    _pressed = value;
    _settle();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    Widget child = widget.builder(context, _focused);
    if (_focused) {
      child = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.focus.withAlpha(235), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(120),
              blurRadius: 18,
            ),
          ],
        ),
        child: child,
      );
    }
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              },
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _scale,
            child: child,
            builder: (context, child) =>
                Transform.scale(scale: _scale.value, child: child),
          ),
        ),
      ),
    );
  }
}
