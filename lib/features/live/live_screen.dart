import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/device/ui_metrics.dart';
import '../../core/widgets/channel_card.dart';
import '../../core/widgets/filter_chip_bar.dart';
import '../../core/widgets/state_views.dart';
import '../../data/api/app_exception.dart';
import '../../data/model_exports.dart';
import '../../providers/content_providers.dart';
import '../common/navigation.dart';
import '../player/player_args.dart';
import '../../core/widgets/floating_nav_bar.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  ChannelCategory _category = ChannelCategory.all;

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            m.pagePadding,
            16 + MediaQuery.paddingOf(context).top,
            m.pagePadding,
            4,
          ),
          child: Text(
            AppStrings.navLive,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        FilterChipBar<ChannelCategory>(
          values: ChannelCategory.values,
          selected: _category,
          labelOf: (c) => c.label,
          onSelected: (c) => setState(() => _category = c),
        ),
        Expanded(child: _ChannelGrid(key: ValueKey(_category), category: _category)),
      ],
    );
  }
}

class _ChannelGrid extends ConsumerStatefulWidget {
  const _ChannelGrid({super.key, required this.category});

  final ChannelCategory category;

  @override
  ConsumerState<_ChannelGrid> createState() => _ChannelGridState();
}

class _ChannelGridState extends ConsumerState<_ChannelGrid> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.hasClients && _controller.position.extentAfter < 500) {
        ref.read(channelsProvider(widget.category).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    final state = ref.watch(channelsProvider(widget.category));
    final notifier = ref.read(channelsProvider(widget.category).notifier);

    if (state.isInitialLoading) return const LoadingView();
    if (state.error != null && state.items.isEmpty) {
      return ErrorView(
        message: errorMessageOf(state.error!),
        onRetry: notifier.refresh,
      );
    }
    if (state.items.isEmpty) {
      return const EmptyView(
        title: AppStrings.noChannels,
        icon: Icons.live_tv_rounded,
      );
    }

    final count = state.items.length + (state.hasMore ? 1 : 0);
    return GridView.builder(
      controller: _controller,
      padding: EdgeInsets.fromLTRB(
        m.pagePadding - 4,
        10,
        m.pagePadding - 4,
        32 + navReserve(context),
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: m.channelExtent,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }
        final channel = state.items[index];
        return ChannelCard(
          name: channel.name,
          logoUrl: channel.logoUrl,
          categoryLabel: channel.category.label,
          onTap: () => openPlayer(
            context,
            PlayerArgs(
              id: channel.id,
              title: channel.name,
              subtitle: channel.category.label,
              streamUrl: channel.streamUrl,
              isLive: true,
              channels: state.items,
              channelIndex: index,
            ),
          ),
        );
      },
    );
  }
}
