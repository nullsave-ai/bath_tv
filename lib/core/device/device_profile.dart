import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DeviceType { phone, tablet, tv }

/// اكتشاف نوع الجهاز.
///
/// التلفاز (Android TV / Google TV) يُكتشف من النظام عبر قناة أصلية،
/// أما الهاتف والتابلت فيُفرَّقان بحسب عرض الشاشة.
class DeviceProfile {
  DeviceProfile._();

  static const MethodChannel _channel = MethodChannel('bath_tv/device');

  static bool isTelevision = false;

  static Future<bool> detectTelevision() async {
    try {
      final result = await _channel.invokeMethod<bool>('isTelevision');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}

extension DeviceTypeContext on BuildContext {
  DeviceType get deviceType {
    if (DeviceProfile.isTelevision) return DeviceType.tv;
    final width = MediaQuery.sizeOf(this).width;
    return width >= 600 ? DeviceType.tablet : DeviceType.phone;
  }

  bool get isTv => deviceType == DeviceType.tv;
}
