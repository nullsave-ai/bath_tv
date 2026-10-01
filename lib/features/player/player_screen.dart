import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/device/device_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/math_utils.dart';
import '../../core/widgets/app_buttons.dart';
import '../../data/model_exports.dart';
import '../../providers/history_providers.dart';
import '../../providers/settings_provider.dart';
import 'player_args.dart';

/// مشغل الفيديو: HLS، ملء الشاشة، جودة الفيديو، إعادة الاتصال التلقائي،
/// وتحكم كامل بالريموت وحفظ آخر موضع مشاهدة.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.args});

  final PlayerArgs args;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player _player;
  late final VideoController _video;
  late final ContinueWatchingNotifier _progressStore;
  late final AppSettings _settings;

  final FocusNode _rootFocus = FocusNode(debugLabel: 'player-root');
  final FocusNode _playFocus = FocusNode(debugLabel: 'player-play');
  final List<StreamSubscription<dynamic>> _subs = [];

  // المحتوى الحالي (يتغير عند التنقل بين القنوات).
  late String _id;
  late String _title;
  late String _subtitle;
  late String _url;
  late int _channelIndex;

  bool _controlsVisible = true;
  bool _playing = false;
  bool _buffering = true;
  bool _reconnecting = false;
  bool _failed = false;
  bool _fullscreen = true;
  bool _disposed = false;
  bool _qualityApplied = false;
  int _attempts = 0;
  int? _selectedHeight; // null = تلقائي
  List<VideoTrack> _qualityTracks = const [];

  Timer? _hideTimer;
  Timer? _reconnectTimer;
  Timer? _stallTimer;
  Timer? _saveTimer;

  bool get _isLive => widget.args.isLive;
  bool get _isTv => DeviceProfile.isTelevision;
  bool get _hasChannels => _isLive && widget.args.channels.length > 1;

  @override
  void initState() {
    super.initState();
    _progressStore = ref.read(continueWatchingProvider.notifier);
    _settings = ref.read(settingsProvider);

    _applyArgs();

    _player = Player();
    _video = VideoController(_player);

    WakelockPlus.enable();
    _enterFullscreen();

    _subs.addAll([
      _player.stream.playing.listen((value) {
        if (!mounted) return;
        setState(() => _playing = value);
        if (value && !_buffering) _onHealthy();
        if (value) {
          _scheduleHide();
        } else {
          _hideTimer?.cancel();
        }
      }),
      _player.stream.buffering.listen(_onBuffering),
      _player.stream.error.listen(_onError),
      _player.stream.completed.listen(_onCompleted),
      _player.stream.tracks.listen(_onTracks),
    ]);

    final start = _settings.resumePlayback
        ? widget.args.startPosition
        : Duration.zero;
    _open(start: start);

    _saveTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _saveProgress());
    _scheduleHide();
  }

  void _applyArgs() {
    final args = widget.args;
    if (args.channels.isNotEmpty) {
      _channelIndex =
          math.min(math.max(args.channelIndex, 0), args.channels.length - 1);
      final channel = args.channels[_channelIndex];
      _id = channel.id;
      _title = channel.name;
      _subtitle = channel.category.label;
      _url = channel.streamUrl;
    } else {
      _channelIndex = 0;
      _id = args.id;
      _title = args.title;
      _subtitle = args.subtitle;
      _url = args.streamUrl;
    }
  }

  // ------------------------------------------------------------ التشغيل

  Future<void> _open({Duration? start}) async {
    if (_disposed) return;
    try {
      await _player.open(
        Media(_url, start: _isLive ? null : start),
        play: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onHealthy() {
    _stallTimer?.cancel();
    _attempts = 0;
    if ((_reconnecting || _failed) && mounted) {
      setState(() {
        _reconnecting = false;
        _failed = false;
      });
    }
  }

  void _onBuffering(bool value) {
    if (!mounted) return;
    setState(() => _buffering = value);
    _stallTimer?.cancel();
    if (value) {
      // إن طال التخزين المؤقت دون تقدم نعتبر الاتصال منقطعاً.
      _stallTimer = Timer(const Duration(seconds: 25), _scheduleReconnect);
    } else if (_playing) {
      _onHealthy();
    }
  }

  void _onError(String message) {
    if (message.isEmpty) return;
    _scheduleReconnect();
  }

  void _onCompleted(bool completed) {
    if (!completed || _disposed) return;
    if (_isLive) {
      _scheduleReconnect();
    } else {
      _progressStore.remove(_id);
      if (mounted) setState(() => _controlsVisible = true);
    }
  }

  void _scheduleReconnect() {
    if (_disposed || !mounted) return;
    if (_reconnectTimer?.isActive ?? false) return;
    if (!_settings.autoReconnect || _attempts >= AppConfig.maxReconnectAttempts) {
      setState(() {
        _failed = true;
        _reconnecting = false;
        _controlsVisible = true;
      });
      return;
    }
    _attempts++;
    setState(() {
      _reconnecting = true;
      _failed = false;
    });
    final delay = Duration(seconds: math.min(_attempts * 2, 10));
    _reconnectTimer = Timer(delay, () {
      if (_disposed) return;
      final position = _player.state.position;
      _open(start: _isLive ? null : position);
    });
  }

  void _retryNow() {
    _reconnectTimer?.cancel();
    _attempts = 0;
    setState(() {
      _failed = false;
      _reconnecting = false;
      _buffering = true;
    });
    final position = _player.state.position;
    _open(start: _isLive ? null : position);
  }

  void _switchChannel(int delta) {
    final channels = widget.args.channels;
    if (channels.length < 2) return;
    final next = (_channelIndex + delta) % channels.length;
    final channel = channels[next];
    _reconnectTimer?.cancel();
    _stallTimer?.cancel();
    setState(() {
      _channelIndex = next;
      _id = channel.id;
      _title = channel.name;
      _subtitle = channel.category.label;
      _url = channel.streamUrl;
      _attempts = 0;
      _failed = false;
      _reconnecting = false;
      _buffering = true;
      _qualityApplied = false;
      _qualityTracks = const [];
      _selectedHeight = null;
    });
    _open();
    _showControls();
  }

  // ------------------------------------------------------------ الجودة

  void _onTracks(Tracks tracks) {
    if (!mounted) return;
    final withHeight =
        tracks.video.where((t) => (t.h ?? 0) > 0).toList()
          ..sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));
    final seen = <int>{};
    final unique = <VideoTrack>[
      for (final t in withHeight)
        if (seen.add(t.h!)) t,
    ];
    setState(() => _qualityTracks = unique);
    if (!_qualityApplied && unique.isNotEmpty) {
      _qualityApplied = true;
      _applyPreferredQuality(unique);
    }
  }

  void _applyPreferredQuality(List<VideoTrack> tracks) {
    final preferred = _settings.preferredQuality;
    if (preferred == 0) return;
    VideoTrack? best;
    for (final t in tracks) {
      // القائمة مرتبة تنازلياً: أول عنصر لا يتجاوز الجودة المفضلة.
      if ((t.h ?? 0) <= preferred) {
        best = t;
        break;
      }
    }
    best ??= tracks.last;
    _player.setVideoTrack(best);
    setState(() => _selectedHeight = best!.h);
  }

  Future<void> _openQualityMenu() async {
    _hideTimer?.cancel();
    if (_qualityTracks.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.quality),
          content: const Text(AppStrings.qualityUnavailable),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.ok),
            ),
          ],
        ),
      );
    } else {
      final choice = await showDialog<int>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text(AppStrings.quality),
          children: [
            _qualityOption(ctx, AppStrings.qualityAuto, -1, _selectedHeight == null),
            for (final t in _qualityTracks)
              _qualityOption(
                ctx,
                qualityLabel(t.h ?? 0),
                t.h ?? 0,
                _selectedHeight == t.h,
              ),
          ],
        ),
      );
      if (choice != null) {
        if (choice < 0) {
          _player.setVideoTrack(VideoTrack.auto());
          setState(() => _selectedHeight = null);
        } else {
          final track = _qualityTracks.firstWhere((t) => t.h == choice);
          _player.setVideoTrack(track);
          setState(() => _selectedHeight = choice);
        }
      }
    }
    _scheduleHide();
  }

  Widget _qualityOption(
    BuildContext ctx,
    String label,
    int value,
    bool selected,
  ) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, value),
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected ? AppColors.primary : Colors.white70,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ حفظ الموضع

  void _saveProgress() {
    if (_isLive || _disposed) return;
    final position = _player.state.position;
    final duration = _player.state.duration;
    if (duration.inSeconds <= 0 || position.inSeconds < 5) return;
    if (duration - position < const Duration(seconds: 30)) {
      _progressStore.remove(_id);
      return;
    }
    _progressStore.save(
      WatchProgress(
        id: _id,
        title: widget.args.title,
        subtitle: widget.args.subtitle,
        posterUrl: widget.args.posterUrl,
        streamUrl: _url,
        positionMs: position.inMilliseconds,
        durationMs: duration.inMilliseconds,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ------------------------------------------------------------ الشاشة والتحكم

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!_isTv) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _leaveFullscreenToPortrait() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  void _restoreSystemUi() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  void _toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    if (_fullscreen) {
      _enterFullscreen();
    } else {
      _leaveFullscreenToPortrait();
    }
    _scheduleHide();
  }

  void _showControls() {
    if (!mounted) return;
    setState(() => _controlsVisible = true);
    _scheduleHide();
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controlsVisible) _playFocus.requestFocus();
      });
    }
  }

  void _hideControls() {
    if (!mounted || _failed) return;
    setState(() => _controlsVisible = false);
    _rootFocus.requestFocus();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_playing || _failed) return;
    _hideTimer = Timer(const Duration(seconds: 4), _hideControls);
  }

  void _seekBy(Duration delta) {
    if (_isLive) return;
    final duration = _player.state.duration;
    var target = _player.state.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    _player.seek(target);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    // مفاتيح الوسائط تعمل دائماً.
    if (key == LogicalKeyboardKey.mediaPlayPause) {
      _player.playOrPause();
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaPlay) {
      _player.play();
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaPause) {
      _player.pause();
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaFastForward) {
      _seekBy(const Duration(seconds: 30));
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaRewind) {
      _seekBy(const Duration(seconds: -30));
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaStop) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (_hasChannels &&
        (key == LogicalKeyboardKey.channelUp ||
            key == LogicalKeyboardKey.pageUp)) {
      _switchChannel(1);
      return KeyEventResult.handled;
    }
    if (_hasChannels &&
        (key == LogicalKeyboardKey.channelDown ||
            key == LogicalKeyboardKey.pageDown)) {
      _switchChannel(-1);
      return KeyEventResult.handled;
    }

    if (!_controlsVisible) {
      // الأدوات مخفية: أي زر توجيه يظهرها، والأسهم الأفقية تقدم/ترجع.
      if (key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter ||
          key == LogicalKeyboardKey.space) {
        _player.playOrPause();
        _showControls();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft) {
        _seekBy(const Duration(seconds: -10));
        _showControls();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        _seekBy(const Duration(seconds: 10));
        _showControls();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowDown) {
        _showControls();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // الأدوات ظاهرة: التنقل بين الأزرار بالتركيز الافتراضي.
    _scheduleHide();
    return KeyEventResult.ignored;
  }

  // ------------------------------------------------------------ دورة الحياة

  @override
  void dispose() {
    _saveProgress();
    _disposed = true;
    _hideTimer?.cancel();
    _reconnectTimer?.cancel();
    _stallTimer?.cancel();
    _saveTimer?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    WakelockPlus.disable();
    _restoreSystemUi();
    _player.dispose();
    _rootFocus.dispose();
    _playFocus.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ الواجهة

  @override
  Widget build(BuildContext context) {
    final stack = _buildStack(context);
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: _buildScaffold(stack),
    );
  }

  Widget _buildScaffold(Widget stack) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _rootFocus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: _fullscreen
            ? stack
            : SafeArea(
                child: Column(
                  children: [
                    AspectRatio(aspectRatio: 16 / 9, child: stack),
                    Expanded(child: _InfoPanel(title: _title, subtitle: _subtitle)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStack(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        Video(
          controller: _video,
          controls: NoVideoControls,
          fill: Colors.black,
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _toggleControls,
          child: const SizedBox.expand(),
        ),
        if ((_buffering || _reconnecting) && !_failed)
          Center(child: _BusyIndicator(reconnecting: _reconnecting, attempt: _attempts)),
        if (_failed)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 56, color: AppColors.error),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.playbackFailed,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: AppStrings.retry,
                  icon: Icons.refresh_rounded,
                  autofocus: true,
                  onPressed: _retryNow,
                ),
              ],
            ),
          ),
        if (_controlsVisible) _buildControls(context),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    final iconSize = _isTv ? 36.0 : 30.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(190),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withAlpha(210),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isTv ? 40 : 16,
              vertical: _isTv ? 28 : 8,
            ),
            child: Column(
              children: [
                _topBar(iconSize),
                const Spacer(),
                _transportRow(iconSize),
                const Spacer(),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(double iconSize) {
    return Row(
      children: [
        AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: AppStrings.back,
          size: iconSize - 4,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _isTv ? 24 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (_subtitle.isNotEmpty)
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70),
                ),
            ],
          ),
        ),
        if (_isLive) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.live,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              AppStrings.liveNow,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
        AppIconButton(
          icon: Icons.settings_rounded,
          tooltip: AppStrings.quality,
          size: iconSize - 4,
          onPressed: _openQualityMenu,
        ),
        if (!_isTv) ...[
          const SizedBox(width: 6),
          AppIconButton(
            icon: _fullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            tooltip: _fullscreen
                ? AppStrings.exitFullscreen
                : AppStrings.fullscreen,
            size: iconSize - 4,
            onPressed: _toggleFullscreen,
          ),
        ],
      ],
    );
  }

  Widget _transportRow(double iconSize) {
    final big = iconSize + 14;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_hasChannels)
          AppIconButton(
            icon: Icons.skip_previous_rounded,
            tooltip: AppStrings.previousChannel,
            size: iconSize,
            onPressed: () => _switchChannel(-1),
          )
        else if (!_isLive)
          AppIconButton(
            icon: Icons.replay_10_rounded,
            tooltip: AppStrings.rewind10,
            size: iconSize,
            onPressed: () => _seekBy(const Duration(seconds: -10)),
          ),
        const SizedBox(width: 26),
        AppIconButton(
          icon: _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          tooltip: _playing ? AppStrings.pause : AppStrings.play,
          size: big,
          focusNode: _playFocus,
          onPressed: () {
            _player.playOrPause();
            _scheduleHide();
          },
        ),
        const SizedBox(width: 26),
        if (_hasChannels)
          AppIconButton(
            icon: Icons.skip_next_rounded,
            tooltip: AppStrings.nextChannel,
            size: iconSize,
            onPressed: () => _switchChannel(1),
          )
        else if (!_isLive)
          AppIconButton(
            icon: Icons.forward_10_rounded,
            tooltip: AppStrings.forward10,
            size: iconSize,
            onPressed: () => _seekBy(const Duration(seconds: 10)),
          ),
      ],
    );
  }

  Widget _bottomBar() {
    if (_isLive) return const SizedBox(height: 8);
    return _SeekBar(player: _player, interactive: !_isTv);
  }
}

class _BusyIndicator extends StatelessWidget {
  const _BusyIndicator({required this.reconnecting, required this.attempt});

  final bool reconnecting;
  final int attempt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(strokeWidth: 3.5),
        ),
        if (reconnecting) ...[
          const SizedBox(height: 14),
          Text(
            '${AppStrings.reconnecting} ($attempt/${AppConfig.maxReconnectAttempts})',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}

/// شريط التقدم: يُحدَّث من تدفق الموضع فقط دون إعادة بناء المشغل كاملاً.
class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.player, required this.interactive});

  final Player player;
  final bool interactive;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    return StreamBuilder<Duration>(
      stream: player.stream.duration,
      initialData: player.state.duration,
      builder: (context, durationSnap) {
        final duration = durationSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.stream.position,
          initialData: player.state.position,
          builder: (context, positionSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final maxMs = math.max(duration.inMilliseconds, 1).toDouble();
            final posMs = clampD(position.inMilliseconds.toDouble(), 0.0, maxMs);
            final value = _drag ?? posMs;

            // الخط الزمني يبقى من اليسار إلى اليمين ليتوافق مع أسهم الريموت.
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  Text(
                    formatDuration(Duration(milliseconds: value.round())),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: widget.interactive
                        ? Slider(
                            min: 0,
                            max: maxMs,
                            value: clampD(value, 0.0, maxMs),
                            onChanged: (v) => setState(() => _drag = v),
                            onChangeEnd: (v) {
                              player.seek(Duration(milliseconds: v.round()));
                              setState(() => _drag = null);
                            },
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value / maxMs,
                              minHeight: 6,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatDuration(duration),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
