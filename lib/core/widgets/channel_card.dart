import 'package:flutter/material.dart';

import '../../data/model_exports.dart';
import '../constants/app_strings.dart';
import '../device/device_profile.dart';
import '../theme/app_colors.dart';
import '../utils/math_utils.dart';
import 'app_image.dart';
import 'focusable.dart';

/// شبكة القنوات: ثلاث بطاقات أفقية في الصف (أربع على التلفاز).
SliverGridDelegate channelGridDelegate(BuildContext context) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.isTv ? 4 : 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.12,
  );
}

Color categoryColor(ChannelCategory category) {
  switch (category) {
    case ChannelCategory.sports:
      return const Color(0xFF16A34A);
    case ChannelCategory.news:
      return const Color(0xFFDC2626);
    case ChannelCategory.entertainment:
      return const Color(0xFFF59E0B);
    case ChannelCategory.kids:
      return const Color(0xFFEC4899);
    case ChannelCategory.movies:
      return const Color(0xFF8B5CF6);
    case ChannelCategory.series:
      return const Color(0xFF06B6D4);
    case ChannelCategory.all:
      return AppColors.primary;
  }
}

/// بطاقة قناة أفقية تستغل كامل المساحة: الشعار فوق خلفية بلون التصنيف، ونقطة بث
/// نابضة، وشريط زجاجي سفلي فيه اسم القناة والبرنامج الحالي وتقدمه.
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.autofocus = false,
  });

  final Channel channel;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tv = context.isTv;
    final tint = categoryColor(channel.category);
    return Focusable(
      autofocus: autofocus,
      onTap: onTap,
      borderRadius: 16,
      focusScale: 1.06,
      builder: (context, focused) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  tint.withAlpha(AppColors.dark ? 120 : 150),
                  Color.alphaBlend(
                    tint.withAlpha(30),
                    AppColors.dark ? AppColors.surface : AppColors.surfaceHigh,
                  ),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 22, 14, 44),
                  child: AnimatedScale(
                    scale: focused ? 1.1 : 1,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    child: AppImage(
                      url: channel.logoUrl,
                      fit: BoxFit.contain,
                      cacheWidth: 260,
                      iconData: Icons.live_tv_rounded,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 6,
                  start: 6,
                  child: const _LiveBadge(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _InfoStrip(channel: channel, tv: tv),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.channel, required this.tv});

  final Channel channel;
  final bool tv;

  @override
  Widget build(BuildContext context) {
    final program = channel.programTitle.isEmpty
        ? channel.category.label
        : channel.programTitle;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withAlpha(0), Colors.black.withAlpha(185)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            channel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: tv ? 15 : 11.5,
              height: 1.25,
            ),
          ),
          Text(
            program,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: tv ? 12.5 : 9.5,
              height: 1.3,
            ),
          ),
          if (channel.programProgress > 0) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: clampD(channel.programProgress, 0.0, 1.0),
                minHeight: 2.5,
                backgroundColor: Colors.white.withAlpha(50),
                valueColor: AlwaysStoppedAnimation(AppColors.accentText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => CustomPaint(
                painter: _PulseDotPainter(t: _pulse.value, color: AppColors.live),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            AppStrings.liveNow,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDotPainter extends CustomPainter {
  const _PulseDotPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      2.6 + 2.4 * t,
      Paint()..color = color.withAlpha((150 * (1 - t)).round()),
    );
    canvas.drawCircle(c, 2.8, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PulseDotPainter old) => old.t != t;
}
