import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../domain/entities/gym_challenge.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';
import '../challenge/challenge_screen.dart';

/// "Mis Gimnasios": everything split into conquered vs pending.
/// Pending gyms never spoil their description or location; they only
/// show a number so the participant understands how much is left.
class TreasuresScreen extends StatelessWidget {
  const TreasuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final treasures = List.of(controller.treasures)
      ..sort((a, b) => a.order.compareTo(b.order));

    final found = treasures.where(
        (t) => controller.statusOf(t) == TreasureStatus.discovered);
    final pending = treasures
        .where((t) => controller.statusOf(t) != TreasureStatus.discovered);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: [
        _Summary(
          found: found.length,
          total: treasures.length,
          pending: pending.length,
        ),
        Text(
          'Conquistados',
          style: _sectionStyle,
        ),
        if (found.isEmpty) _EmptyFoundCard(),
        for (final t in found) _TreasureTile(treasure: t, revealed: true),
        const SizedBox(height: 20),
        Text('Por conquistar', style: _sectionStyle),
        for (final t in pending) _TreasureTile(treasure: t, revealed: false),
        const SizedBox(height: 20),
      ],
    );
  }

  TextStyle get _sectionStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.found, required this.total, required this.pending});

  final int found;
  final int total;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        '$found conquistados · $pending pendientes · $total total',
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

class _TreasureTile extends StatelessWidget {
  const _TreasureTile({required this.treasure, required this.revealed});

  final TreasureItem treasure;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          if (revealed) return; // Already conquered
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChallengeScreen(gym: treasure),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: (revealed ? AppColors.success : AppColors.surfaceAlt)
              .withValues(alpha: 0.25),
          child: revealed
              ? const Icon(Icons.check_rounded, color: AppColors.success)
              : Text(
                  treasure.order.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        title: Row(
          children: [
            if (treasure.track != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  treasure.track!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                revealed
                    ? (treasure.gymName ?? treasure.title)
                    : 'Gimnasio #${treasure.order.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        subtitle: revealed
            ? Text(
                treasure.locationDescription,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              )
            : Row(
                children: [
                  Icon(
                    _getChallengeTypeIcon(treasure.challengeType),
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${treasure.pointValue} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
        trailing: revealed
            ? null
            : (treasure.isActive
                ? StatusPill(
                    label: _getChallengeTypeName(treasure.challengeType),
                    color: AppColors.primary,
                  )
                : const StatusPill(
                    label: 'No disponible',
                    color: AppColors.danger,
                    icon: Icons.lock_rounded,
                  )),
      ),
    );
  }

  IconData _getChallengeTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.qr:
        return Icons.qr_code_rounded;
      case ChallengeType.trivia:
        return Icons.quiz_rounded;
      case ChallengeType.riddle:
        return Icons.lightbulb_outline_rounded;
      case ChallengeType.code:
        return Icons.code_rounded;
      case ChallengeType.completion:
        return Icons.location_on_rounded;
      case ChallengeType.social:
        return Icons.people_rounded;
    }
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

class _EmptyFoundCard extends StatelessWidget {
  const _EmptyFoundCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.explore_rounded,
                  color: AppColors.primarySoft, size: 40),
              SizedBox(height: 10),
              Text(
                'Aún no has encontrado ninguno.\n¡Sal a explorar!',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
