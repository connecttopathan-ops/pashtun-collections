import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ColorSwatchSelector extends StatelessWidget {
  final List<String> colors;
  final String? selected;
  final ValueChanged<String> onSelected;

  const ColorSwatchSelector({
    super.key,
    required this.colors,
    this.selected,
    required this.onSelected,
  });

  static Color _colorFromName(String name) {
    final map = {
      'red': const Color(0xFFD94F3D),
      'blue': const Color(0xFF3B82F6),
      'green': const Color(0xFF22C55E),
      'yellow': const Color(0xFFEAB308),
      'orange': const Color(0xFFF97316),
      'purple': const Color(0xFFA855F7),
      'pink': const Color(0xFFEC4899),
      'black': const Color(0xFF1A1A1A),
      'white': const Color(0xFFFFFFFF),
      'cream': const Color(0xFFF5ECD7),
      'beige': const Color(0xFFF5F0E8),
      'brown': const Color(0xFF92400E),
      'navy': const Color(0xFF1E3A5F),
      'maroon': const Color(0xFF7F1D1D),
      'teal': const Color(0xFF0D9488),
      'gold': AppColors.primary,
      'silver': const Color(0xFF9CA3AF),
      'grey': const Color(0xFF6B6B6B),
      'gray': const Color(0xFF6B6B6B),
      'ivory': const Color(0xFFFFFAF0),
      'peach': const Color(0xFFFFCBA4),
      'rust': const Color(0xFFB45309),
    };
    return map[name.toLowerCase()] ?? AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((colorName) {
        final isSelected = selected == colorName;
        final swatch = _colorFromName(colorName);
        final isLight = swatch.computeLuminance() > 0.7;

        return GestureDetector(
          onTap: () => onSelected(colorName),
          child: Tooltip(
            message: colorName,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: swatch,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isLight
                          ? AppColors.divider
                          : Colors.transparent,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: isLight ? AppColors.textPrimary : Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ColorNameDisplay extends StatelessWidget {
  final String colorName;
  const ColorNameDisplay({super.key, required this.colorName});

  @override
  Widget build(BuildContext context) => Text(
        colorName,
        style: AppTextStyles.labelMedium,
      );
}
