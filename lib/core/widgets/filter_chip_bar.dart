import 'package:flutter/material.dart';

import '../device/ui_metrics.dart';
import '../theme/app_colors.dart';
import 'focusable.dart';

/// شريط تصفية أفقي (تصنيفات القنوات، أنواع المحتوى) يدعم الريموت.
class FilterChipBar<T> extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final m = UiMetrics.of(context);
    return SizedBox(
      height: m.chipHeight + 12,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding, vertical: 6),
        itemCount: values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = values[index];
          final isSelected = value == selected;
          return Focusable(
            onTap: () => onSelected(value),
            borderRadius: 30,
            focusScale: 1.06,
            builder: (context, focused) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                height: m.chipHeight - 6,
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 24 : 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [
                          AppColors.primary,
                          Color.alphaBlend(
                              Colors.white.withAlpha(46), AppColors.primary),
                        ])
                      : null,
                  color: isSelected ? null : AppColors.glassFill,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withAlpha(60)
                        : AppColors.glassBorder,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(110),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(labelOf(value)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
