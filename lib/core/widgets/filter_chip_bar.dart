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
            borderRadius: 10,
            focusScale: 1.04,
            builder: (context, focused) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: m.chipHeight - 8,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(AppColors.dark ? 70 : 28)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withAlpha(AppColors.dark ? 200 : 160)
                        : AppColors.glassBorder,
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isSelected
                        ? AppColors.accentText
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
