import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/device_profile.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/state_views.dart';
import '../../data/api/app_exception.dart';
import '../../data/model_exports.dart';
import '../../providers/content_providers.dart';
import '../common/navigation.dart';

/// بانر رئيسي يعرض أول عنصر من "الأكثر مشاهدة".
class HeroBanner extends ConsumerWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = UiMetrics.of(context);
    final state = ref.watch(contentSectionProvider(HomeSection.popular));

    if (state.isInitialLoading) {
      return SizedBox(height: m.heroHeight, child: const LoadingView());
    }
    if (state.items.isEmpty) {
      if (state.error != null) {
        return SizedBox(
          height: m.heroHeight,
          child: ErrorView(
            message: errorMessageOf(state.error!),
            onRetry: () => ref
                .read(contentSectionProvider(HomeSection.popular).notifier)
                .refresh(),
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return _HeroContent(item: state.items.first, m: m);
  }
}

class _HeroContent extends ConsumerWidget {
  const _HeroContent({required this.item, required this.m});

  final ContentItem item;
  final UiMetrics m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = m.device != DeviceType.phone;
    final image =
        item.backdropUrl.isNotEmpty ? item.backdropUrl : item.posterUrl;

    return SizedBox(
      height: m.heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(url: image, cacheWidth: 1280),
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
                        AppColors.background.withAlpha(245),
                        AppColors.background.withAlpha(150),
                        Colors.transparent,
                      ]
                    : [
                        Colors.transparent,
                        AppColors.background.withAlpha(120),
                        AppColors.background,
                      ],
                stops: wide ? const [0.0, 0.45, 1.0] : const [0.25, 0.65, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withAlpha(wide ? 255 : 0),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              m.pagePadding,
              m.pagePadding,
              m.pagePadding,
              20,
            ),
            child: Align(
              alignment: wide
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.bottomStart,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 560 : 640),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: 18, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(item.rating.toStringAsFixed(1)),
                        const SizedBox(width: 10),
                        Text('${item.year}'),
                        const SizedBox(width: 10),
                        Text(item.type.label),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppButton(
                          label: AppStrings.watchNow,
                          icon: Icons.play_arrow_rounded,
                          autofocus: true,
                          onPressed: () => item.hasEpisodes
                              ? openDetails(context, item)
                              : playContent(context, ref, item),
                        ),
                        AppButton(
                          label: AppStrings.details,
                          icon: Icons.info_outline_rounded,
                          primary: false,
                          onPressed: () => openDetails(context, item),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
