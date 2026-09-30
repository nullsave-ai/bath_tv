import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../device/device_profile.dart';
import '../theme/app_colors.dart';
import 'app_image.dart';
import 'focusable.dart';

/// بطاقة قناة مباشرة: الشعار والاسم والتصنيف.
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.categoryLabel,
    required this.onTap,
    this.autofocus = false,
  });

  final String name;
  final String logoUrl;
  final String categoryLabel;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tv = context.isTv;
    return Focusable(
      autofocus: autofocus,
      onTap: onTap,
      borderRadius: 16,
      builder: (context, focused) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ColoredBox(
                        color: AppColors.surfaceHigh,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AppImage(
                            url: logoUrl,
                            fit: BoxFit.contain,
                            cacheWidth: 300,
                            iconData: Icons.live_tv_rounded,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 6,
                      start: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.live,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          AppStrings.liveNow,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: tv ? 16 : 13.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: Text(
                  categoryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: tv ? 13.5 : 11.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
