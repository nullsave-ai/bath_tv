import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../data/model_exports.dart';
import '../../providers/history_providers.dart';
import '../../providers/settings_provider.dart';
import '../details/details_screen.dart';
import '../player/player_args.dart';
import '../player/player_screen.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void openDetails(BuildContext context, ContentItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => DetailsScreen(item: item)),
  );
}

void openPlayer(BuildContext context, PlayerArgs args) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PlayerScreen(args: args)),
  );
}

/// تشغيل فيلم أو حلقة مع استئناف من آخر موضع محفوظ عند تفعيل الخيار.
void playContent(
  BuildContext context,
  WidgetRef ref,
  ContentItem item, {
  Episode? episode,
}) {
  final url = episode?.streamUrl ?? item.streamUrl;
  if (url.isEmpty) {
    showMessage(context, AppStrings.noSource);
    return;
  }
  final id = episode?.id ?? item.id;
  final saved = ref.read(continueWatchingProvider.notifier).byId(id);
  final resume = ref.read(settingsProvider).resumePlayback;
  final subtitle = episode == null
      ? ''
      : '${AppStrings.seasonWord} ${episode.season} - ${episode.title}';
  openPlayer(
    context,
    PlayerArgs(
      id: id,
      title: item.title,
      subtitle: subtitle,
      posterUrl: item.posterUrl,
      streamUrl: url,
      startPosition: resume && saved != null
          ? Duration(milliseconds: saved.positionMs)
          : Duration.zero,
    ),
  );
}

/// فتح المشغل من عنصر "متابعة المشاهدة".
void playProgress(BuildContext context, WidgetRef ref, WatchProgress p) {
  final resume = ref.read(settingsProvider).resumePlayback;
  openPlayer(
    context,
    PlayerArgs(
      id: p.id,
      title: p.title,
      subtitle: p.subtitle,
      posterUrl: p.posterUrl,
      streamUrl: p.streamUrl,
      startPosition:
          resume ? Duration(milliseconds: p.positionMs) : Duration.zero,
    ),
  );
}
