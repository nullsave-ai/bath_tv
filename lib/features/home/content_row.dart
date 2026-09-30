import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/state_views.dart';
import '../../data/api/app_exception.dart';
import '../../data/model_exports.dart';
import '../../providers/content_providers.dart';
import '../../providers/paged_notifier.dart';
import '../common/navigation.dart';

/// صف أفقي لقسم من الشاشة الرئيسية، يحمّل المزيد تدريجياً عند الاقتراب من النهاية.
class ContentRow extends ConsumerStatefulWidget {
  const ContentRow({super.key, required this.section});

  final HomeSection section;

  @override
  ConsumerState<ContentRow> createState() => _ContentRowState();
}

class _ContentRowState extends ConsumerState<ContentRow> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    if (_controller.position.extentAfter < 500) {
      ref.read(contentSectionProvider(widget.section).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    final state = ref.watch(contentSectionProvider(widget.section));

    return Padding(
      padding: EdgeInsets.only(bottom: m.rowGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: widget.section.title),
          SizedBox(height: m.cardHeight + 14, child: _body(context, m, state)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, UiMetrics m, PagedState<ContentItem> state) {
    if (state.isInitialLoading) {
      return _RowSkeleton(m: m);
    }
    if (state.error != null && state.items.isEmpty) {
      return ErrorView(
        message: errorMessageOf(state.error!),
        onRetry: () =>
            ref.read(contentSectionProvider(widget.section).notifier).refresh(),
      );
    }
    if (state.items.isEmpty) {
      return const EmptyView(title: AppStrings.noContent);
    }
    final count = state.items.length + (state.hasMore ? 1 : 0);
    return ListView.builder(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding - 4, vertical: 6),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const SizedBox(
            width: 56,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }
        final item = state.items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: SizedBox(
            width: m.cardWidth,
            child: PosterCard(
              imageUrl: item.posterUrl,
              title: item.title,
              subtitle: '${item.year} • ${item.type.label}',
              rating: item.rating,
              onTap: () => openDetails(context, item),
            ),
          ),
        );
      },
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton({required this.m});

  final UiMetrics m;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding - 4, vertical: 6),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: m.cardWidth - 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 10,
                width: m.cardWidth * 0.6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
