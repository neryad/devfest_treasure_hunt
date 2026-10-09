import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/snack_bar_utils.dart';
import '../../../domain/entities/finalist_result.dart';
import '../../../state/app_scope.dart';

/// Read-only provisional results visible to participants.
class FinalResultsScreen extends StatelessWidget {
  const FinalResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final finalists = controller.finalResults;

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await controller.refresh();
        } catch (_) {
          if (context.mounted) showNetworkError(context);
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          const _ResultsRuleCard(),
          const SizedBox(height: 16),
          if (finalists.isEmpty)
            const _EmptyResults()
          else
            for (final finalist in finalists) ...[
              _PublicFinalistCard(finalist: finalist),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ResultsRuleCard extends StatelessWidget {
  const _ResultsRuleCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceAlt,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Gana quien complete los 8 gimnasios con la mayor puntuación. '
                'En caso de empate, gana quien complete primero.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('client-finalists-empty'),
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
              'Los resultados aparecerán cuando alguien complete los 8 gimnasios.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicFinalistCard extends StatelessWidget {
  const _PublicFinalistCard({required this.finalist});

  final FinalistResult finalist;

  @override
  Widget build(BuildContext context) {
    final isLeader = finalist.position == 1;
    return Card(
      color: isLeader ? AppColors.surfaceAlt : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isLeader ? AppColors.amber : AppColors.surfaceAlt,
          foregroundColor: isLeader ? Colors.black87 : AppColors.textPrimary,
          child: Text(
            '#${finalist.position}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          '${finalist.name} (${finalist.nickname})',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${finalist.points} puntos · 8/8 medallas\n'
            'Completó: ${formatDateTime(finalist.completedAt)}',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ),
        trailing: isLeader
            ? const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.amber,
              )
            : null,
      ),
    );
  }
}
