import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/device_profile.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/focusable.dart';
import '../../data/model_exports.dart';
import '../../providers/history_providers.dart';
import '../common/navigation.dart';

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = UiMetrics.of(context);
    final wide = m.device != DeviceType.phone;
    final progress = ref.watch(continueWatchingProvider);
    final progressById = {for (final p in progress) p.id: p};

    // العنصر الذي سيُستأنف: أحدث حلقة مشاهدة أو الفيلم نفسه.
    WatchProgress? resume;
    Episode? resumeEpisode;
    if (item.hasEpisodes) {
      for (final p in progress) {
        final match = item.episodes.where((e) => e.id == p.id);
        if (match.isNotEmpty) {
          resume = p;
          resumeEpisode = match.first;
          break;
        }
      }
    } else {
      resume = progressById[item.id];
    }

    final backdrop =
        item.backdropUrl.isNotEmpty ? item.backdropUrl : item.posterUrl;

    void play() {
      if (item.hasEpisodes) {
        playContent(context, ref, item,
            episode: resumeEpisode ?? item.episodes.first);
      } else {
        playContent(context, ref, item);
      }
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (wide)
            Positioned.fill(
              child: AppImage(
                url: backdrop,
                cacheWidth: 1280,
                alignment: Alignment.topCenter,
              ),
            )
          else
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: m.heroHeight * 1.1,
              child: AppImage(
                url: backdrop,
                cacheWidth: 1280,
                alignment: Alignment.topCenter,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: wide
                    ? AlignmentDirectional.centerStart
                    : Alignment.topCenter,
                end: wide
                    ? AlignmentDirectional.centerEnd
                    : Alignment.bottomCenter,
                colors: wide
                    ? [
                        AppColors.background,
                        AppColors.background.withAlpha(215),
                        AppColors.background.withAlpha(60),
                      ]
                    : [
                        Colors.transparent,
                        AppColors.background.withAlpha(200),
                        AppColors.background,
                      ],
                stops: wide ? const [0.0, 0.5, 1.0] : const [0.1, 0.42, 0.6],
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    m.pagePadding,
                    8,
                    m.pagePadding,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: AppIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: AppStrings.back,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        SizedBox(height: wide ? 24 : m.heroHeight * 0.42),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: wide ? 640 : 720),
                          child: _Info(
                            item: item,
                            playLabel: resume != null
                                ? AppStrings.resume
                                : AppStrings.watchNow,
                            onPlay: play,
                          ),
                        ),
                        if (item.hasEpisodes) ...[
                          const SizedBox(height: 26),
                          Text(
                            AppStrings.episodes,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
                if (item.hasEpisodes)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
                    sliver: SliverList.separated(
                      itemCount: item.episodes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final episode = item.episodes[index];
                        return _EpisodeTile(
                          episode: episode,
                          progress: progressById[episode.id],
                          onTap: () => playContent(
                            context,
                            ref,
                            item,
                            episode: episode,
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.item,
    required this.playLabel,
    required this.onPlay,
  });

  final ContentItem item;
  final String playLabel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final metaStyle = TextStyle(color: AppColors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(item.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            Text('${item.year}', style: metaStyle),
            Text(item.type.label, style: metaStyle),
            if (item.durationMinutes > 0)
              Text('${item.durationMinutes} ${AppStrings.minutesUnit}',
                  style: metaStyle),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final genre in item.genres)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(genre, style: const TextStyle(fontSize: 12.5)),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          item.description,
          style: TextStyle(height: 1.6, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 18),
        AppButton(
          label: playLabel,
          icon: Icons.play_arrow_rounded,
          autofocus: true,
          onPressed: onPlay,
        ),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.progress,
    required this.onTap,
  });

  final Episode episode;
  final WatchProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Focusable(
      onTap: onTap,
      borderRadius: 14,
      focusScale: 1.02,
      builder: (context, focused) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${episode.number}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.seasonWord} ${episode.season} - ${episode.title}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (episode.durationMinutes > 0)
                      Text(
                        '${episode.durationMinutes} ${AppStrings.minutesUnit}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    if (progress != null) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress!.fraction,
                        minHeight: 3,
                        backgroundColor: AppColors.glassBorder,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.play_circle_outline_rounded, size: 30),
            ],
          ),
        );
      },
    );
  }
}
