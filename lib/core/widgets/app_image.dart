import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// صورة مخزنة مؤقتاً مع حالة انتظار وخطأ، وتقليل استهلاك الذاكرة.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheWidth = 400,
    this.alignment = Alignment.center,
    this.iconData = Icons.image_not_supported_rounded,
  });

  final String url;
  final BoxFit fit;
  final int cacheWidth;
  final Alignment alignment;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.surfaceHigh,
      child: Center(
        child: Icon(iconData, color: AppColors.textSecondary, size: 32),
      ),
    );
    if (url.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment,
      memCacheWidth: cacheWidth,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => ColoredBox(color: AppColors.surfaceHigh),
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}
