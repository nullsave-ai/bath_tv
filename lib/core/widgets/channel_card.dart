import 'package:flutter/material.dart';

import '../../data/model_exports.dart';
import '../constants/app_strings.dart';
import '../device/device_profile.dart';
import '../theme/app_colors.dart';
import 'app_image.dart';
import 'focusable.dart';

/// شبكة القنوات: ثلاث بطاقات أفقية في الصف (أربع على التلفاز).
SliverGridDelegate channelGridDelegate(BuildContext context) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.isTv ? 4 : 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.25,
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

/// بطاقة قناة أفقية: الصورة تملأ البطاقة تقريباً، بلا شريط سفلي. يظهر اسم القناة
/// فقط عند التركيز (ريموت) أو إن لم يتوفر شعار.
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
    final noLogo = channel.logoUrl.isEmpty;
    return Focusable(
      autofocus: autofocus,
      onTap: onTap,
      borderRadius: 12,
      focusScale: 1.06,
      builder: (context, focused) {
        return Semantics(
          button: true,
          label: channel.name,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    tint.withAlpha(AppColors.dark ? 62 : 90),
                    Color.alphaBlend(
                      tint.withAlpha(16),
                      AppColors.dark ? AppColors.surface : AppColors.surfaceHigh,
                    ),
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: AppImage(
                      url: channel.logoUrl,
                      fit: BoxFit.contain,
                      cacheWidth: 300,
                      iconData: Icons.live_tv,
                    ),
                  ),
                  PositionedDirectional(
                    top: 7,
                    start: 7,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.live,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(200),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  if (focused || noLogo)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(0),
                              Colors.black.withAlpha(170),
                            ],
                          ),
                        ),
                        child: Text(
                          channel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: tv ? 15 : 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
