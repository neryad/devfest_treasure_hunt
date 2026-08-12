import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../domain/entities/leaderboard_entry.dart';
import '../../../state/app_scope.dart';

/// Live ranking. Sort: discovered count desc, then elapsed time asc.
/// The current participant is highlighted.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final entries = controller.leaderboard;
    final myId = controller.participant?.id;

    if (entries.isEmpty) {
      return const Center(
        child: Text('Aún no hay participantes.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = entry.participantId == myId;
        return _RankRow(entry: entry, isMe: isMe);
      },
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final position = entry.position;
    final name = entry.name;
    final nickname = entry.nickname;
    final discoveredCount = entry.discoveredCount;
    final totalTreasures = entry.totalTreasures;
    final elapsed = entry.elapsed;
    final status = entry.status;

    final medal = switch (position) {
      1 => const Icon(Icons.emoji_events_rounded, color: AppColors.amber),
      2 => const Icon(Icons.workspace_premium_rounded, color: Color(0xFFCDD3E6)),
      3 => const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB47927)),
      _ => Text(
          '$position',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
    };

    return Card(
      color: isMe ? AppColors.surfaceAlt : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 34, child: Center(child: medal)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isMe ? AppColors.primarySoft : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$nickname · ${status.name}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$discoveredCount/$totalTreasures',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                  ),
                ),
                Text(
                  formatElapsed(elapsed),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}