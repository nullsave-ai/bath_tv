import 'package:flutter/material.dart';

import '../device/device_profile.dart';
import '../theme/app_colors.dart';
import 'app_image.dart';
import 'focusable.dart';
import '../utils/math_utils.dart';

/// بطاقة ملصق موحدة للمحتوى (أفلام/مسلسلات/أنمي/متابعة المشاهدة).
///
/// تملأ المساحة الممنوحة لها: الصورة تأخذ المتبقي والنص أسفلها.
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.rating,
    this.progress,
    this.autofocus = false,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double? rating;
  final double? progress;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tv = context.isTv;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Focusable(
      autofocus: autofocus,
      onTap: onTap,
      borderRadius: 14,
      builder: (context, focused) {
        return Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(
                        url: imageUrl,
                        cacheWidth: (220 * dpr).round(),
                      ),
                      if (rating != null && rating! > 0)
                        PositionedDirectional(
                          top: 6,
                          start: 6,
                          child: _RatingBadge(rating: rating!),
                        ),
                      if (progress != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LinearProgressIndicator(
                            value: clampD(progress!, 0.0, 1.0),
                            minHeight: 4,
                            backgroundColor: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: tv ? 16 : 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: tv ? 13.5 : 11.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(170),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
