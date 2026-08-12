import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../state/app_scope.dart';

/// Shown when the participant discovers every treasure.
/// Completing the run does NOT mean being the official winner: the final
/// position depends on the official ranking.
class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final participant = controller.participant!;
    final position = controller.approximateRank ?? controller.leaderboard.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1B00), AppColors.backgroundGradientTop],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _TrophyAnimation(),
                  const SizedBox(height: 28),
                  const Text(
                    '¡Completaste la aventura!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${participant.name} · ${participant.nickname}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Has encontrado todos los tesoros de DevFest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Tesoros',
                          value: '${controller.totalTreasures}/'
                              '${controller.totalTreasures}',
                          icon: Icons.explore_rounded,
                          accent: AppColors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: 'Tiempo total',
                          value: formatElapsed(controller.elapsed),
                          icon: Icons.timer_rounded,
                          accent: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Posición demo',
                          value: '#$position',
                          icon: Icons.leaderboard_rounded,
                          accent: AppColors.primarySoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: StatCard(
                          label: 'Premio',
                          value: '¡Reclama!',
                          icon: Icons.card_giftcard_rounded,
                          accent: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'El ranking oficial determina la posición final. '
                        'Dirígete al organizador para verificar y reclamar el '
                        'premio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrophyAnimation extends StatelessWidget {
  const _TrophyAnimation();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.amber, Color(0xFF8A5A00)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withValues(alpha: 0.55),
              blurRadius: 48,
              spreadRadius: 6,
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          size: 84,
          color: Colors.white,
        ),
      ),
    );
  }
}