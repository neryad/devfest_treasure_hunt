import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../domain/entities/clue.dart';
import '../../../state/app_scope.dart';

/// "Mis pistas": every treasure has a clue. Discovering the treasure unlocks
/// its clue. Clues guide, they never enforce an order.
class CluesScreen extends StatelessWidget {
  const CluesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final clues = controller.buildClues();
    final unlocked = clues.where((c) => c.unlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '$unlocked de ${clues.length} pistas desbloqueadas',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        for (final clue in clues) _ClueCard(clue: clue),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ClueCard extends StatelessWidget {
  const _ClueCard({required this.clue});

  final Clue clue;

  @override
  Widget build(BuildContext context) {
    final unlocked = clue.unlocked;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: unlocked
                    ? AppColors.amber.withValues(alpha: 0.2)
                    : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                unlocked ? Icons.tips_and_updates_rounded : Icons.lock_rounded,
                color: unlocked ? AppColors.amber : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pista #${clue.treasureId.split('-').last}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: unlocked
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (unlocked)
                        StatusPill(
                          label: clue.consulted ? 'Consultada' : 'Nueva',
                          color: clue.consulted
                              ? AppColors.secondary
                              : AppColors.amber,
                          icon: clue.consulted
                              ? Icons.done_all_rounded
                              : Icons.circle,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    unlocked
                        ? clue.text
                        : 'Encuentra el tesoro para desbloquear esta pista.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}