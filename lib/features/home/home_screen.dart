import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/device/device_profile.dart';
import '../../core/device/ui_metrics.dart';
import '../../data/model_exports.dart';
import '../../providers/content_providers.dart';
import 'content_row.dart';
import 'continue_watching_row.dart';
import 'hero_banner.dart';
import '../../core/widgets/floating_nav_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _sections = [
    HomeSection.latest,
    HomeSection.popular,
    HomeSection.movies,
    HomeSection.series,
    HomeSection.anime,
  ];

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      for (final s in _sections)
        ref.read(contentSectionProvider(s).notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = UiMetrics.of(context);
    final list = ListView(
      padding: EdgeInsets.only(bottom: m.rowGap + 8 + navReserve(context)),
      children: [
        const HeroBanner(),
        SizedBox(height: m.rowGap - 6),
        const ContinueWatchingRow(),
        for (final s in _sections) ContentRow(section: s),
      ],
    );
    if (context.isTv) return list;
    return RefreshIndicator(onRefresh: () => _refresh(ref), child: list);
  }
}
