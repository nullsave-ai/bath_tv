import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/history_providers.dart';
import '../common/navigation.dart';

/// صف "متابعة المشاهدة" ويظهر فقط عند وجود مواضع محفوظة.
class ContinueWatchingRow extends ConsumerWidget {
  const ContinueWatchingRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(continueWatchingProvider);
    if (items.isEmpty) return const SizedBox.shrink();
    final m = UiMetrics.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: m.rowGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppStrings.continueWatching),
          SizedBox(
            height: m.cardHeight + 14,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: m.pagePadding - 4,
                vertical: 6,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final p = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: m.cardWidth,
                    child: PosterCard(
                      imageUrl: p.posterUrl,
                      title: p.title,
                      subtitle: p.subtitle.isEmpty
                          ? AppStrings.resume
                          : p.subtitle,
                      progress: p.fraction,
                      onTap: () => playProgress(context, ref, p),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
