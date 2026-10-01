import 'dart:async';

import 'package:flutter/material.dart';

/// ظهور متتابع خفيف لأول عناصر الشبكة فقط (تلاشي وصعود)، وبقية العناصر
/// تُرسم مباشرة كي لا يتأثر التمرير.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.index >= 12) return;
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _c = c;
    _timer = Timer(Duration(milliseconds: widget.index * 40), () {
      if (mounted) c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    final curved = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(curved),
        child: widget.child,
      ),
    );
  }
}
