import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'device_profile.dart';

/// أبعاد الواجهة بحسب نوع الجهاز، لتجربة مخصصة للهاتف والتابلت والتلفاز.
class UiMetrics {
  const UiMetrics({
    required this.device,
    required this.pagePadding,
    required this.cardWidth,
    required this.gridExtent,
    required this.channelExtent,
    required this.heroHeight,
    required this.rowGap,
    required this.chipHeight,
    required this.iconSize,
  });

  final DeviceType device;
  final double pagePadding;
  final double cardWidth;
  final double gridExtent;
  final double channelExtent;
  final double heroHeight;
  final double rowGap;
  final double chipHeight;
  final double iconSize;

  /// ارتفاع النص أسفل بطاقة الملصق (العنوان + المعلومات).
  double get cardTextHeight => device == DeviceType.tv ? 64 : 52;

  double get cardHeight => cardWidth * 1.5 + cardTextHeight;

  factory UiMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final device = context.deviceType;
    switch (device) {
      case DeviceType.phone:
        return UiMetrics(
          device: device,
          pagePadding: 16,
          cardWidth: (size.width * 0.34).clamp(108.0, 150.0),
          gridExtent: 150,
          channelExtent: 165,
          heroHeight: math.min(size.height * 0.5, 420),
          rowGap: 22,
          chipHeight: 42,
          iconSize: 24,
        );
      case DeviceType.tablet:
        return UiMetrics(
          device: device,
          pagePadding: 28,
          cardWidth: 172,
          gridExtent: 190,
          channelExtent: 200,
          heroHeight: math.min(size.height * 0.5, 460),
          rowGap: 28,
          chipHeight: 46,
          iconSize: 26,
        );
      case DeviceType.tv:
        final card = (size.width / 6.2).clamp(150.0, 300.0);
        return UiMetrics(
          device: device,
          pagePadding: 48,
          cardWidth: card,
          gridExtent: card,
          channelExtent: (size.width / 5.4).clamp(170.0, 320.0),
          heroHeight: size.height * 0.56,
          rowGap: 30,
          chipHeight: 52,
          iconSize: 30,
        );
    }
  }
}
