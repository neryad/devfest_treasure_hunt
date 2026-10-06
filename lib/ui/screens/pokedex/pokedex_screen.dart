import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/treasure_icons.dart';
import '../../../domain/entities/gym_challenge.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';
import '../challenge/challenge_screen.dart';


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
    final name = participant?.name ?? 'Entrenador';
    final nickname = participant?.nickname ?? 'Dev';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        // --- TRAINER CARD HERO ---
        _TrainerCard(
          name: name,
          nickname: nickname,
          level: level,
          medals: medals,
          total: gyms.length > 0 ? gyms.length : 8,
          points: points,
        ),
        const SizedBox(height: 24),

        // --- SECTION HEADER ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '8 Gimnasios Tecnológicos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Toca un gimnasio para ver su reto y ubicación',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$medals / ${gyms.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primarySoft,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- BADGE GRID ---
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemCount: gyms.length,
          itemBuilder: (context, index) {
            final gym = gyms[index];
            final isEarned = discoveredIds.contains(gym.id);
            return _GymBadgeCard(
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
    final trackColor = _getTrackColor(gym.track);
    final medalPath = getMedalAssetPath(gym.track);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: trackColor.withValues(alpha: 0.15),
                    border: Border.all(color: trackColor, width: 2),
                    boxShadow: isEarned
                        ? [
                            BoxShadow(
                              color: trackColor.withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        medalPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          _getTrackIcon(gym.track),
                          size: 36,
                          color: trackColor,
                        ),
                      ),
                    ),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gym.locationDescription,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primarySoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              gym.description,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailChip(
                  icon: Icons.track_changes_rounded,
                  label: _getTrackName(gym.track),
                  color: trackColor,
                ),
                _DetailChip(
                  icon: Icons.psychology_rounded,
                  label: _getChallengeTypeName(gym.challengeType),
                  color: AppColors.amber,
                ),
                _DetailChip(
                  icon: Icons.star_rounded,
                  label: '${gym.challenge?.points ?? gym.pointValue} pts',
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (isEarned)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_rounded, color: AppColors.secondary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      '¡Medalla Conquistada!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: trackColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: trackColor.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChallengeScreen(gym: gym),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text(
                  'Desafiar este Gimnasio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Color _getTrackColor(String? track) {
    switch (track) {
      case 'android':
        return const Color(0xFF4285F4); // Blue GDG
      case 'ia':
        return const Color(0xFF57CAFF); // Halftone Blue / Cyan
      case 'cloud':
        return const Color(0xFFF9AB00); // Yellow GDG
      case 'security':
        return const Color(0xFFEA4335); // Red GDG
      case 'web':
        return const Color(0xFF34A853); // Green GDG
      case 'startup':
        return const Color(0xFFFF7DAF); // Pastel / Halftone Red
      case 'speaker':
        return const Color(0xFFFFD427); // Halftone Yellow / Amber
      case 'community':
        return const Color(0xFF5CDB6D); // Halftone Green
      default:
        return AppColors.primary;
    }
  }

  static IconData _getTrackIcon(String? track) {
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
        return Icons.groups_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  static String _getTrackName(String? track) {
    switch (track) {
      case 'android':
        return 'Android';
      case 'ia':
        return 'IA & Agentes';
      case 'cloud':
        return 'Cloud';
      case 'security':
        return 'Seguridad';
      case 'web':
        return 'Web & UX';
      case 'startup':
        return 'Emprendimiento';
      case 'speaker':
        return 'Charlas';
      case 'community':
        return 'Comunidad GDG';
      default:
        return 'General';
    }
  }

  static String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.qr:
        return 'Escaneo QR';
      case ChallengeType.trivia:
        return 'Trivia Técnica';
      case ChallengeType.riddle:
        return 'Acertijo';
      case ChallengeType.code:
        return 'Reto de Código';
      case ChallengeType.completion:
        return 'Reto Presencial';
      case ChallengeType.social:
        return 'Reto Social';
    }
  }
}

// --- TRAINER CARD WIDGET ---
class _TrainerCard extends StatelessWidget {
  const _TrainerCard({
    required this.name,
    required this.nickname,
    required this.level,
    required this.medals,
    required this.total,
    required this.points,
  });

  final String name;
  final String nickname;
  final String level;
  final int medals;
  final int total;
  final int points;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (medals / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3856), Color(0xFF1B2236)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primarySoft],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '😎',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              nickname,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.amberSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceAlt,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TrainerStat(
                  icon: Icons.emoji_events_rounded,
                  label: 'Medallas',
                  value: '$medals / $total',
                  color: AppColors.amber,
                ),
                _TrainerStat(
                  icon: Icons.star_rounded,
                  label: 'Puntaje',
                  value: '$points pts',
                  color: AppColors.primarySoft,
                ),
                _TrainerStat(
                  icon: Icons.military_tech_rounded,
                  label: 'Rango',
                  value: medals == total ? 'Master 🏆' : '${(progress * 100).toInt()}%',
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainerStat extends StatelessWidget {
  const _TrainerStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- GYM BADGE CARD ---
class _GymBadgeCard extends StatelessWidget {
  const _GymBadgeCard({
    required this.gym,
    required this.isEarned,
    required this.onTap,
  });

  final TreasureItem gym;
  final bool isEarned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trackColor = PokedexScreen._getTrackColor(gym.track);
    final medalPath = getMedalAssetPath(gym.track);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned
              ? trackColor.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEarned ? trackColor : AppColors.surfaceAlt,
            width: isEarned ? 2 : 1,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: trackColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 68,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isEarned
                        ? trackColor.withValues(alpha: 0.15)
                        : AppColors.surfaceAlt.withValues(alpha: 0.5),
                    border: Border.all(
                      color: isEarned ? trackColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: isEarned
                          ? Image.asset(
                              medalPath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                PokedexScreen._getTrackIcon(gym.track),
                                size: 28,
                                color: trackColor,
                              ),
                            )
                          : Opacity(
                              opacity: 0.45,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                                child: Image.asset(
                                  medalPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    PokedexScreen._getTrackIcon(gym.track),
                                    size: 28,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,

                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isEarned ? AppColors.secondary : AppColors.surfaceAlt,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Icon(
                      isEarned ? Icons.check_rounded : Icons.lock_rounded,
                      size: 11,
                      color: isEarned ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              gym.gymName?.replaceFirst('Gimnasio ', '') ?? gym.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isEarned ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isEarned ? trackColor : AppColors.surfaceAlt).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${gym.challenge?.points ?? gym.pointValue} pts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isEarned ? trackColor : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
