import 'package:flutter/material.dart';

/// ألوان الهوية للوضعين الليلي والنهاري.
///
/// القيم تعتمد على [dark] الذي يُضبط من جذر التطبيق عند تغيير المظهر.
class AppColors {
  AppColors._();

  static bool dark = true;

  static Color get background =>
      dark ? const Color(0xFF0B0D12) : const Color(0xFFEEF1F8);
  static Color get surface =>
      dark ? const Color(0xFF141821) : const Color(0xFFFFFFFF);
  static Color get surfaceHigh =>
      dark ? const Color(0xFF1E2431) : const Color(0xFFE3E8F3);
  static Color get textPrimary =>
      dark ? const Color(0xFFF2F4F8) : const Color(0xFF12151C);
  static Color get textSecondary =>
      dark ? const Color(0xFF9AA3B5) : const Color(0xFF586074);

  static Color get primary => const Color(0xFF6C63FF);
  static Color get accent =>
      dark ? const Color(0xFFFFC145) : const Color(0xFFE59A00);
  static Color get error => const Color(0xFFFF5A5F);
  static Color get live => const Color(0xFFE5383B);

  /// إطار التركيز بالريموت.
  static Color get focus =>
      dark ? const Color(0xFFFFFFFF) : const Color(0xFF1B1F2A);

  // الصبغة الزجاجية
  static Color get glassFill => dark
      ? const Color(0xFFFFFFFF).withAlpha(20)
      : const Color(0xFFFFFFFF).withAlpha(150);
  static Color get glassBorder => dark
      ? const Color(0xFFFFFFFF).withAlpha(34)
      : const Color(0xFFFFFFFF).withAlpha(210);
  static Color get navFill => dark
      ? const Color(0xFF181C28).withAlpha(150)
      : const Color(0xFFFFFFFF).withAlpha(150);
  static Color get cloud => dark
      ? const Color(0xFFB9B4FF).withAlpha(70)
      : const Color(0xFFFFFFFF).withAlpha(230);
}
