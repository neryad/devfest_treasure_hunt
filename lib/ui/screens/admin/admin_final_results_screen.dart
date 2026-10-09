import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/snack_bar_utils.dart';
import '../../../domain/entities/finalist_result.dart';
import '../../../state/app_scope.dart';

class AdminFinalResultsScreen extends StatelessWidget {
  const AdminFinalResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final finalists = controller.finalResults;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados finales')),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await controller.refresh();
          } catch (_) {
            if (context.mounted) showNetworkError(context);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            const _RuleCard(),
            const SizedBox(height: 16),
            if (finalists.isEmpty)
              const _EmptyFinalists()
            else
              for (final finalist in finalists) ...[
                _FinalistCard(finalist: finalist),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceAlt,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rule_rounded, color: AppColors.primarySoft),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Solo participan quienes completen los 8 gimnasios. Gana la '
                'mayor puntuación; en caso de empate, quien complete primero.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFinalists extends StatelessWidget {
  const _EmptyFinalists();

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('admin-finalists-empty'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: const [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Aún no hay finalistas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cuando una persona complete los 8 gimnasios aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalistCard extends StatelessWidget {
  const _FinalistCard({required this.finalist});

  final FinalistResult finalist;

  @override
  Widget build(BuildContext context) {
    final isLeader = finalist.position == 1;
    return Card(
      key: ValueKey('admin-finalist-${finalist.participantId}'),
      color: isLeader ? AppColors.surfaceAlt : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isLeader ? AppColors.amber : AppColors.surface,
              foregroundColor: isLeader
                  ? Colors.black87
                  : AppColors.textPrimary,
              child: Text(
                '#${finalist.position}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${finalist.name} (${finalist.nickname})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${finalist.points} puntos · 8/8 medallas',
                    style: const TextStyle(
                      color: AppColors.primarySoft,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completó: ${formatDateTime(finalist.completedAt)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    'Duración: ${formatElapsed(finalist.elapsed)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (isLeader) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Ganador provisional',
                      style: TextStyle(
                        color: AppColors.amber,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
