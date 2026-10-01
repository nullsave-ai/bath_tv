import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/channel_card.dart';
import '../../core/widgets/filter_chip_bar.dart';
import '../../core/widgets/focusable.dart';
import '../../core/widgets/poster_card.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/state_views.dart';
import '../../data/api/app_exception.dart';
import '../../data/model_exports.dart';
import '../../providers/history_providers.dart';
import '../../providers/search_provider.dart';
import '../common/navigation.dart';
import '../player/player_args.dart';
import '../../core/widgets/floating_nav_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 600) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _useQuery(String query) {
    _text.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    ref.read(searchProvider.notifier).setQuery(query);
    ref.read(searchProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            m.pagePadding,
            14 + MediaQuery.paddingOf(context).top,
            m.pagePadding,
            4,
          ),
          child: TextField(
            controller: _text,
            textInputAction: TextInputAction.search,
            onChanged: notifier.setQuery,
            onSubmitted: (_) => notifier.submit(),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: state.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _text.clear();
                        notifier.setQuery('');
                      },
                    ),
            ),
          ),
        ),
        if (!state.isIdle)
          FilterChipBar<SearchFilter>(
            values: SearchFilter.values,
            selected: state.filter,
            labelOf: (f) => f.label,
            onSelected: notifier.setFilter,
          ),
        Expanded(child: _body(context, m, state)),
      ],
    );
  }

  Widget _body(BuildContext context, UiMetrics m, SearchState state) {
    if (state.isIdle) return _History(m: m, onPick: _useQuery);
    if (state.loading) return const LoadingView();
    if (state.error != null) {
      return ErrorView(
        message: errorMessageOf(state.error!),
        onRetry: () => ref.read(searchProvider.notifier).retry(),
      );
    }
    if (!state.hasResults) {
      return EmptyView(
        title: AppStrings.noResults,
        subtitle: AppStrings.noResultsFor(state.query.trim()),
        icon: Icons.search_off_rounded,
      );
    }

    final notifier = ref.read(searchProvider.notifier);
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w800);

    return CustomScrollView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        if (state.content.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(m.pagePadding, 12, m.pagePadding, 8),
            sliver: SliverToBoxAdapter(
              child: Text(AppStrings.contentResults, style: titleStyle),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: m.pagePadding - 4),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: m.gridExtent,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.58,
              ),
              itemCount: state.content.length,
              itemBuilder: (context, index) {
                final item = state.content[index];
                return Reveal(
                  index: index,
                  child: PosterCard(
                  imageUrl: item.posterUrl,
                  title: item.title,
                  subtitle: '${item.year} • ${item.type.label}',
                  rating: item.rating,
                  onTap: () {
                    notifier.remember();
                    openDetails(context, item);
                  },
                  ),
                );
              },
            ),
          ),
        ],
        if (state.channels.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(m.pagePadding, 18, m.pagePadding, 8),
            sliver: SliverToBoxAdapter(
              child: Text(AppStrings.channelResults, style: titleStyle),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: m.pagePadding - 4),
            sliver: SliverGrid.builder(
              gridDelegate: channelGridDelegate(context),
              itemCount: state.channels.length,
              itemBuilder: (context, index) {
                final channel = state.channels[index];
                return Reveal(
                  index: index,
                  child: ChannelCard(
                  channel: channel,
                  onTap: () {
                    notifier.remember();
                    openPlayer(
                      context,
                      PlayerArgs(
                        id: channel.id,
                        title: channel.name,
                        subtitle: channel.category.label,
                        streamUrl: channel.streamUrl,
                        isLive: true,
                        channels: state.channels,
                        channelIndex: index,
                      ),
                    );
                  },
                ),
                );
              },
            ),
          ),
        ],
        if (state.loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 32 + navReserve(context))),
      ],
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.m, required this.onPick});

  final UiMetrics m;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    if (history.isEmpty) {
      return const EmptyView(
        title: AppStrings.searchPrompt,
        subtitle: AppStrings.searchPromptSub,
        icon: Icons.search_rounded,
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(
        m.pagePadding,
        m.pagePadding,
        m.pagePadding,
        m.pagePadding + navReserve(context),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.searchHistory,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            AppButton(
              label: AppStrings.clearHistory,
              icon: Icons.delete_outline_rounded,
              primary: false,
              onPressed: () =>
                  ref.read(searchHistoryProvider.notifier).clear(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final q in history)
              Focusable(
                onTap: () => onPick(q),
                borderRadius: 30,
                builder: (context, focused) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(q),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
