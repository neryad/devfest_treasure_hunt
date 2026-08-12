import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../state/app_scope.dart';

/// DEMO admin panel: metrics, ranking, treasure availability toggles and the
/// participant list. No real auth — the whole point is showing how the event
/// would be controlled.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    final participants = controller.participants;
    final completed = participants.where((p) => p.isCompleted).length;
    final active = participants.length - completed;
    final activeTreasures = controller.treasures.where((t) => t.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel admin · Demo'),
        actions: [
          IconButton(
            tooltip: 'Resetear datos demo',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            const SectionHeader(title: 'Métricas del evento'),
            _MetricsGrid(
              participants: participants.length,
              active: active,
              completed: completed,
              treasures: controller.treasures.length,
              activeTreasures: activeTreasures,
            ),
            const SectionHeader(title: 'Ranking'),
            const _AdminRanking(),
            const SectionHeader(title: 'Gestión de tesoros'),
            const _TreasureManagement(),
            const SectionHeader(title: 'Participantes'),
            const _ParticipantsList(),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '¿Resetear la demo?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Se restaurarán los datos de ejemplo del evento.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!context.mounted) return;
      final controller = AppScope.read(context);
      await controller.resetDemo();
      if (context.mounted && !controller.hasParticipant) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.participants,
    required this.active,
    required this.completed,
    required this.treasures,
    required this.activeTreasures,
  });

  final int participants;
  final int active;
  final int completed;
  final int treasures;
  final int activeTreasures;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Participantes',
                value: '$participants',
                icon: Icons.people_rounded,
                accent: AppColors.primarySoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'En progreso',
                value: '$active',
                icon: Icons.directions_run_rounded,
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
                label: 'Completados',
                value: '$completed',
                icon: Icons.emoji_events_rounded,
                accent: AppColors.amber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Tesoros activos',
                value: '$activeTreasures/$treasures',
                icon: Icons.explore_rounded,
                accent: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminRanking extends StatelessWidget {
  const _AdminRanking();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final top = controller.leaderboard.take(5).toList();

    return Card(
      child: Column(
        children: [
          for (final entry in top)
            ListTile(
              dense: true,
              leading: Text(
                '#${entry.position}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.amber,
                ),
              ),
              title: Text(
                '${entry.name} (${entry.nickname})',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Text(
                '${entry.discoveredCount}/${entry.totalTreasures} · '
                '${formatElapsed(entry.elapsed)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (top.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin datos'),
            ),
        ],
      ),
    );
  }
}

class _TreasureManagement extends StatelessWidget {
  const _TreasureManagement();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final treasures = List.of(controller.treasures)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Card(
      child: Column(
        children: [
          for (final t in treasures)
            _TreasureRow(
              key: ValueKey(t.id),
              isActive: t.isActive,
              title: t.title,
              discoverCount: controller.participants
                  .where((p) => p.discoveredTreasureIds.contains(t.id))
                  .length,
              onChanged: (v) =>
                  controller.setTreasureActive(t.id, v),
            ),
        ],
      ),
    );
  }
}

class _TreasureRow extends StatelessWidget {
  const _TreasureRow({
    super.key,
    required this.isActive,
    required this.title,
    required this.discoverCount,
    required this.onChanged,
  });

  final bool isActive;
  final String title;
  final int discoverCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: StatusPill(
        label: isActive ? 'Activo' : 'Inactivo',
        color: isActive ? AppColors.success : AppColors.danger,
        icon: isActive ? Icons.check_circle_rounded : Icons.lock_rounded,
      ),
      title: Text(title, style: const TextStyle(fontSize: 13.5)),
      subtitle: Text('Descubrimientos: $discoverCount',
          style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: isActive,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

class _ParticipantsList extends StatelessWidget {
  const _ParticipantsList();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final sorted = List.of(controller.participants)
      ..sort((a, b) {
        final byCount = b.discoveredCount.compareTo(a.discoveredCount);
        if (byCount != 0) return byCount;
        final aT = a.isCompleted
            ? a.completedAt!.difference(a.startedAt)
            : DateTime.now().difference(a.startedAt);
        final bT = b.isCompleted
            ? b.completedAt!.difference(b.startedAt)
            : DateTime.now().difference(b.startedAt);
        return aT.compareTo(bT);
      });

    return Card(
      child: Column(
        children: [
          for (final p in sorted)
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surfaceAlt,
                child: Text(
                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
              title: Text('${p.name} (${p.nickname})',
                  style: const TextStyle(fontSize: 13.5)),
              subtitle: Text(
                formatElapsed(p.isCompleted
                    ? p.completedAt!.difference(p.startedAt)
                    : DateTime.now().difference(p.startedAt)),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${p.discoveredCount}/${controller.totalTreasures}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(
                    label: p.isCompleted ? 'Completado' : 'En progreso',
                    color:
                        p.isCompleted ? AppColors.success : AppColors.secondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}