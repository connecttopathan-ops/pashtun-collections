import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelected;
  final Set<String> unavailableSizes;

  const SizeSelector({
    super.key,
    required this.sizes,
    this.selected,
    required this.onSelected,
    this.unavailableSizes = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((size) {
        final isSelected = selected == size;
        final isUnavailable = unavailableSizes.contains(size);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: isUnavailable ? null : () => onSelected(size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isUnavailable
                          ? AppColors.textHint.withOpacity(0.3)
                          : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Text(
                    size,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isUnavailable
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                    ),
                  ),
                  if (isUnavailable)
                    Positioned.fill(
                      child: CustomPaint(painter: _StrikethroughPainter()),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textHint.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
