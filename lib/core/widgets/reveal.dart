import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/math_utils.dart';

/// ظهور متتابع: العنصر يتلاشى ويصعد ويكبر بنعومة بعد تأخير يعتمد على ترتيبه.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: clampI(widget.index % 9, 0, 9) * 45);
    _timer = Timer(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 26),
            child: Transform.scale(scale: 0.94 + 0.06 * v, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
