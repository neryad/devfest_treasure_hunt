import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Segmented progress bar (one segment per treasure).
class TreasureProgressBar extends StatelessWidget {
  const TreasureProgressBar({
    super.key,
    required this.progress,
    required this.total,
    this.height = 10,
  });

  final double progress;
  final int total;
  final double height;

  @override
  Widget build(BuildContext context) {
    final segments = List.generate(total, (i) => i);
    final filled = (progress * total).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final i in segments) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                color: i < filled
                    ? AppColors.amber
                    : AppColors.surfaceAlt.withValues(alpha: 0.7),
                boxShadow: i < filled
                    ? [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}