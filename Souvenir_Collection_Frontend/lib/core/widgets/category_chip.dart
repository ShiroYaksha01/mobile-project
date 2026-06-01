import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? HColors.secondary
              : HColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label.toUpperCase(),
          style: HText.labelSm.copyWith(
            color: selected
                ? Colors.white
                : HColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}