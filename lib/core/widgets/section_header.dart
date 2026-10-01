import 'package:flutter/material.dart';

import '../device/ui_metrics.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(m.pagePadding, 0, m.pagePadding, 6),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
