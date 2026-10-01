import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../device/device_profile.dart';
import '../theme/app_colors.dart';
import '../utils/math_utils.dart';

class NavBarItem {
  const NavBarItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const double _barHeight = 66;
const double _bottomGap = 12;

/// المساحة التي يجب تركها أسفل المحتوى القابل للتمرير كي لا يختفي خلف الشريط العائم.
double navReserve(BuildContext context) {
  if (context.isTv) return 0;
  return _barHeight + _bottomGap + MediaQuery.viewPaddingOf(context).bottom + 16;
}

/// شريط تنقل عائم زجاجي (blur) بمؤشر سائل بفيزياء نوابض:
/// ينزلق بين الأقسام مع تمدد وارتداد، ويمكن سحبه بالإصبع للتبديل.
class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<NavBarItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(mass: 1, stiffness: 240, damping: 15);

  late final AnimationController _pos =
      AnimationController.unbounded(vsync: this, value: widget.index.toDouble());
  double _target = 0;
  double _itemW = 1;
  bool _dragging = false;

  int get _count => widget.items.length;

  @override
  void initState() {
    super.initState();
    _target = widget.index.toDouble();
  }

  @override
  void didUpdateWidget(FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (!_dragging && widget.index.toDouble() != _target) {
      _springTo(widget.index.toDouble(), _pos.velocity);
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  void _springTo(double target, double velocity) {
    _target = target;
    _pos.animateWith(SpringSimulation(_spring, _pos.value, target, velocity));
  }

  double get _dir => Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _onTapItem(int i) {
    if (i == widget.index) return;
    HapticFeedback.selectionClick();
    widget.onSelect(i);
  }

  void _dragStart(DragStartDetails d) {
    _dragging = true;
    _pos.stop();
  }

  void _dragUpdate(DragUpdateDetails d) {
    final next = _pos.value + _dir * d.delta.dx / _itemW;
    _pos.value = clampD(next, -0.25, _count - 0.75);
  }

  void _dragEnd(DragEndDetails d) {
    _dragging = false;
    final v = _dir * d.velocity.pixelsPerSecond.dx / _itemW;
    final projected = _pos.value + v * 0.10;
    final target = clampI(projected.round(), 0, _count - 1);
    _springTo(target.toDouble(), v);
    if (target != widget.index) {
      HapticFeedback.selectionClick();
      widget.onSelect(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, _bottomGap + bottomInset),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(AppColors.dark ? 120 : 46),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: AppColors.navFill,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      _itemW = (c.maxWidth - 12) / _count;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: _dragStart,
                        onHorizontalDragUpdate: _dragUpdate,
                        onHorizontalDragEnd: _dragEnd,
                        child: AnimatedBuilder(
                          animation: _pos,
                          builder: (context, _) => _buildBar(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar() {
    final pos = _pos.value;
    final velocity = _pos.velocity.abs();
    final stretch = 1 + clampD(velocity * 0.04, 0.0, 0.35);
    final pillW = (_itemW - 8) * stretch;
    final pillH = _barHeight - 16;
    final pillStart = 6 + pos * _itemW + (_itemW - pillW) / 2;

    return Stack(
      children: [
        PositionedDirectional(
          start: pillStart,
          top: (_barHeight - 2 - pillH) / 2,
          width: pillW,
          height: pillH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.primary.withAlpha(AppColors.dark ? 64 : 34),
              border: Border.all(
                color: AppColors.primary.withAlpha(AppColors.dark ? 150 : 110),
                width: 1,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              for (var i = 0; i < _count; i++)
                Expanded(child: _item(i, pos)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(int i, double pos) {
    final item = widget.items[i];
    final near = clampD(1 - (pos - i).abs(), 0.0, 1.0);
    final color = Color.lerp(AppColors.textSecondary, AppColors.accentText, near)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTapItem(i),
      child: Semantics(
        button: true,
        selected: i == widget.index,
        label: item.label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -1 * near),
              child: Icon(
                near > 0.5 ? item.selectedIcon : item.icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: near > 0.5 ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
