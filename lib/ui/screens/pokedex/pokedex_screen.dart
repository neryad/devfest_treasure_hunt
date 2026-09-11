import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/gym_challenge.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final participant = controller.participant;
    final gyms = List.of(controller.treasures)
      ..sort((a, b) => a.order.compareTo(b.order));

    final discoveredIds = participant?.discoveredTreasureIds ?? [];
    final medals = participant?.medals ?? 0;
    final level = participant?.level ?? 'Aprendiz Tech';
    final points = participant?.points ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                      label: '$medals/8',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 16),
                    _StatBadge(
                      label: '$points pts',
                      icon: Icons.star_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Section header
        const Text(
          'Gimnasios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Badge grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: gyms.length,
          itemBuilder: (context, index) {
            final gym = gyms[index];
            final isEarned = discoveredIds.contains(gym.id);
            return _GymBadge(
              gym: gym,
              isEarned: isEarned,
              onTap: () => _showGymDetail(context, gym, isEarned),
            );
          },
        ),
      ],
    );
  }

  void _showGymDetail(BuildContext context, TreasureItem gym, bool isEarned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.surfaceAlt,
                  ),
                  child: Icon(
                    isEarned ? Icons.check_rounded : Icons.lock_rounded,
                    color: isEarned ? AppColors.secondary : AppColors.textSecondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.gymName ?? gym.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        gym.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  label: _getTrackName(gym.track),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: _getChallengeTypeName(gym.challengeType),
                  color: AppColors.amber,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: '${gym.challenge?.points ?? gym.pointValue} pts',
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEarned)
              const Center(
                child: Text(
                  '✅ Gimnasio conquistado',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              )
            else
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/challenge', arguments: gym);
                  },
                  child: const Text('Intentar reto'),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getTrackName(String? track) {
    switch (track) {
      case 'android':
        return 'Android';
      case 'ia':
        return 'IA';
      case 'cloud':
        return 'Cloud';
      case 'security':
        return 'Seguridad';
      case 'web':
        return 'Web';
      case 'startup':
        return 'Startup';
      case 'speaker':
        return 'Speaker';
      case 'community':
        return 'Comunidad';
      default:
        return 'General';
    }
  }

  String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.qr:
        return 'QR';
      case ChallengeType.trivia:
        return 'Trivia';
      case ChallengeType.riddle:
        return 'Acertijo';
      case ChallengeType.code:
        return 'Código';
      case ChallengeType.completion:
        return 'Presencial';
      case ChallengeType.social:
        return 'Social';
    }
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GymBadge extends StatelessWidget {
  const _GymBadge({
    required this.gym,
    required this.isEarned,
    required this.onTap,
  });

  final TreasureItem gym;
  final bool isEarned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned ? AppColors.secondary : AppColors.surfaceAlt,
            width: isEarned ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned
                        ? AppColors.secondary.withValues(alpha: 0.2)
                        : AppColors.surfaceAlt.withValues(alpha: 0.5),
                  ),
                  child: Icon(
                    _getTrackIcon(gym.track),
                    size: 32,
                    color: isEarned ? AppColors.secondary : AppColors.textSecondary,
                  ),
                ),
                if (isEarned)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              gym.gymName?.replaceFirst('Gimnasio ', '') ?? gym.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isEarned ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${gym.challenge?.points ?? gym.pointValue} pts',
              style: TextStyle(
                fontSize: 11,
                color: isEarned ? AppColors.amber : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrackIcon(String? track) {
    switch (track) {
      case 'android':
        return Icons.phone_android_rounded;
      case 'ia':
        return Icons.psychology_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'security':
        return Icons.shield_rounded;
      case 'web':
        return Icons.language_rounded;
      case 'startup':
        return Icons.rocket_launch_rounded;
      case 'speaker':
        return Icons.mic_rounded;
      case 'community':
        return Icons.people_rounded;
      default:
        return Icons.explore_rounded;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
