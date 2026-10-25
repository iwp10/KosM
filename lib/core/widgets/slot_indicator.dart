import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// KosM standard slot indicator component.
/// Specification: text '2/3 penghuni' + row of small dots (filled/empty according to capacity).
class SlotIndicator extends StatelessWidget {
  final int occupied;
  final int capacity;
  final String unit;

  const SlotIndicator({
    super.key,
    required this.occupied,
    required this.capacity,
    this.unit = 'penghuni',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    final isFull = occupied >= capacity;
    final isVacant = occupied == 0;

    Color activeDotColor;
    if (isFull) {
      activeDotColor = AppColors.statusFullText;
    } else if (isVacant) {
      activeDotColor = AppColors.statusVacantText;
    } else {
      activeDotColor = theme.colorScheme.primary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Dots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(capacity, (index) {
            final isFilled = index < occupied;
            return Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? activeDotColor : kosM.outline,
              ),
            );
          }),
        ),
        const SizedBox(width: AppSpacing.xs),
        // Text
        Text(
          '$occupied/$capacity $unit',
          style: AppTextStyles.label.copyWith(color: kosM.textSecondary),
        ),
      ],
    );
  }
}
