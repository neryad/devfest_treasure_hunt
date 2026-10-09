import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/treasure_icons.dart';

import '../../../core/widgets/stat_card.dart';
import '../../../state/app_scope.dart';
import '../completion/completion_screen.dart';
import '../pokedex/pokedex_screen.dart';

/// Unified DevMaster tab: participant overview and gym collection.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final participant = controller.participant;
    if (participant == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final position = controller.approximateRank;
    return RefreshIndicator(
      onRefresh: () => Future<void>.value(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          _Greeting(name: participant.name, nickname: participant.nickname),
          const SizedBox(height: 16),
          _PokedexPreview(
            discovered: controller.discoveredCount,
            total: controller.totalTreasures,
            medals: participant.medals,
            level: participant.level,
            points: participant.points,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Tiempo',
                  value: formatElapsed(controller.elapsed),
                  icon: Icons.timer_rounded,
                  accent: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Posición',
                  value: position == null ? '—' : '#$position',
                  icon: Icons.leaderboard_rounded,
                  accent: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Medallas',
                  value: '${participant.medals}/8',
                  icon: Icons.emoji_events_rounded,
                  accent: AppColors.amber,
                ),
              ),
            ],
          ),
          if (participant.isCompleted) ...[
            const SizedBox(height: 16),
            const _CompletedBanner(),
          ],
          const SizedBox(height: 24),
          const PokedexScreen(embedded: true, showTrainerCard: false),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.nickname});

  final String name;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu aventura',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '$name · $nickname',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PokedexPreview extends StatelessWidget {
  const _PokedexPreview({
    required this.discovered,
    required this.total,
    required this.medals,
    required this.level,
    required this.points,
  });

  final int discovered;
  final int total;
  final int medals;
  final String level;
  final int points;

  static const _trackColors = [
    Color(0xFF4285F4), // Android - Blue
    Color(0xFF57CAFF), // IA - Cyan
    Color(0xFFF9AB00), // Cloud - Yellow
    Color(0xFFEA4335), // Security - Red
    Color(0xFF34A853), // Web - Green
    Color(0xFFFF7DAF), // Startup - Pink
    Color(0xFFFFD427), // Speaker - Amber
    Color(0xFF5CDB6D), // Community - Green
  ];

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (medals / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.amber,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rango de Entrenador',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        level,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amberSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$points pts',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primarySoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // --- 8 BADGES CIRCULAR ROW ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(total > 0 ? total : 8, (i) {
              final isEarned = i < medals;
              final color = i < _trackColors.length
                  ? _trackColors[i]
                  : AppColors.primary;
              final track = i < _trackColors.length
                  ? [
                      'android',
                      'ia',
                      'cloud',
                      'security',
                      'web',
                      'startup',
                      'speaker',
                      'community',
                    ][i]
                  : 'android';
              final medalPath = getMedalAssetPath(track);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEarned
                            ? color.withValues(alpha: 0.14)
                            : color.withValues(alpha: 0.035),
                        border: Border.all(
                          color: isEarned
                              ? color
                              : color.withValues(alpha: 0.14),
                          width: isEarned ? 1.2 : 0.8,
                        ),
                        boxShadow: isEarned
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Opacity(
                        opacity: isEarned ? 1 : 0.35,
                        child: Image.asset(
                          medalPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            isEarned
                                ? Icons.star_rounded
                                : Icons.lock_outline_rounded,
                            size: 14,
                            color: isEarned ? color : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // --- PROGRESS BAR & LABELS ---
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$medals de $total medallas conseguidas',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.amber,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '¡Completaste el reto! Revisa tu posición en el ranking.',
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const CompletionScreen(),
                  ),
                );
              },
              child: const Text('Ver resultado'),
            ),
          ],
        ),
      ),
    );
  }
}
