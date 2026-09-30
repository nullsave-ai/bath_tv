import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'focusable.dart';

/// زر نصي مع أيقونة، يعمل باللمس والريموت.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.autofocus = false,
    this.focusNode,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Focusable(
      autofocus: autofocus,
      focusNode: focusNode,
      onTap: onPressed,
      builder: (context, focused) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: primary ? AppColors.primary : AppColors.glassFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primary ? AppColors.primary : AppColors.glassBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24,
                  color: primary ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: primary ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// زر أيقونة دائري.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 26,
    this.filled = true,
    this.autofocus = false,
    this.focusNode,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final bool filled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final button = Focusable(
      autofocus: autofocus,
      focusNode: focusNode,
      onTap: onPressed,
      borderRadius: 999,
      focusScale: 1.12,
      builder: (context, focused) {
        return Container(
          padding: EdgeInsets.all(size * 0.38),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.black.withAlpha(120) : Colors.transparent,
          ),
          child: Icon(icon, size: size, color: Colors.white),
        );
      },
    );
    if (tooltip == null) return button;
    return Semantics(label: tooltip, button: true, child: button);
  }
}
