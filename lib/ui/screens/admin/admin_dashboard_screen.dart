import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/snack_bar_utils.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_controller.dart';
import '../../../state/app_scope.dart';
import 'admin_ranking_csv.dart';

/// Staff panel: metrics, ranking, gym availability toggles and participant ops.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    final participants = controller.participants;
    final completed = participants.where((p) => p.isCompleted).length;
    final active = participants.length - completed;
    final activeTreasures = controller.treasures
        .where((t) => t.isActive)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Staff'),
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
            const SectionHeader(title: 'Gestión de gimnasios'),
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
      try {
        await controller.resetDemo();
      } catch (_) {
        if (context.mounted) showNetworkError(context);
        return;
      }
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
                label: 'Gimnasios activos',
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: OutlinedButton.icon(
              onPressed: () => _copyRankingCsv(context),
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar ranking CSV'),
            ),
          ),
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

  Future<void> _copyRankingCsv(BuildContext context) async {
    final csv = buildAdminRankingCsv(AppScope.read(context).leaderboard);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ranking CSV copiado')));
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
              treasure: t,
              discoverCount: controller.participants
                  .where((p) => p.discoveredTreasureIds.contains(t.id))
                  .length,
              onChanged: (v) => controller.setTreasureActive(t.id, v),
            ),
        ],
      ),
    );
  }
}

class _TreasureRow extends StatelessWidget {
  const _TreasureRow({
    super.key,
    required this.treasure,
    required this.discoverCount,
    required this.onChanged,
  });

  final TreasureItem treasure;
  final int discoverCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: StatusPill(
        label: treasure.isActive ? 'Activo' : 'Inactivo',
        color: treasure.isActive ? AppColors.success : AppColors.danger,
        icon: treasure.isActive
            ? Icons.check_circle_rounded
            : Icons.lock_rounded,
      ),
      title: Text(treasure.title, style: const TextStyle(fontSize: 13.5)),
      subtitle: Text(
        'Medallas otorgadas: $discoverCount\n'
        'Codigo manual: ${treasure.code}\n'
        'QR: ${treasure.qrValue}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Switch(
        value: treasure.isActive,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

class _ParticipantsList extends StatelessWidget {
  const _ParticipantsList();

  @override
  Widget build(BuildContext context) => const _ParticipantsListBody();
}

class _ParticipantsListBody extends StatefulWidget {
  const _ParticipantsListBody();

  @override
  State<_ParticipantsListBody> createState() => _ParticipantsListBodyState();
}

class _ParticipantsListBodyState extends State<_ParticipantsListBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final sorted = List.of(controller.participants)
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        final byMedals = b.discoveredCount.compareTo(a.discoveredCount);
        if (byMedals != 0) return byMedals;
        final aT = a.isCompleted
            ? a.completedAt!.difference(a.startedAt)
            : DateTime.now().difference(a.startedAt);
        final bT = b.isCompleted
            ? b.completedAt!.difference(b.startedAt)
            : DateTime.now().difference(b.startedAt);
        return aT.compareTo(bT);
      });
    final filtered = sorted.where((p) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.nickname.toLowerCase().contains(q);
    }).toList();

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('admin-participant-search'),
              decoration: const InputDecoration(
                labelText: 'Buscar participante',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          for (final p in filtered)
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surfaceAlt,
                child: Text(
                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              title: Text(
                '${p.name} (${p.nickname})',
                style: const TextStyle(fontSize: 13.5),
              ),
              subtitle: Text(
                formatElapsed(
                  p.isCompleted
                      ? p.completedAt!.difference(p.startedAt)
                      : DateTime.now().difference(p.startedAt),
                ),
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
                    color: p.isCompleted
                        ? AppColors.success
                        : AppColors.secondary,
                  ),
                ],
              ),
              onTap: () => _showParticipantDetail(context, p.id),
            ),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin participantes encontrados'),
            ),
        ],
      ),
    );
  }

  void _showParticipantDetail(BuildContext context, String participantId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final controller = AppScope.of(context);
            final index = controller.participants.indexWhere(
              (p) => p.id == participantId,
            );
            if (index == -1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                if (context.mounted) {
                  showSnack(context, 'El participante ya no existe');
                }
              });
              return const SizedBox.shrink();
            }
            final participant = controller.participants[index];
            final treasures = List.of(controller.treasures)
              ..sort((a, b) => a.order.compareTo(b.order));
            final missing = treasures
                .where((t) => !participant.discoveredTreasureIds.contains(t.id))
                .toList();
            TreasureItem? missingCommunity;
            for (final treasure in missing) {
              if (treasure.id == 'gym-community') {
                missingCommunity = treasure;
                break;
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Detalle de participante',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${participant.name} (${participant.nickname})',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${participant.points} pts · ${participant.medals}/${controller.totalTreasures} medallas',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _showPointAdjustmentDialog(
                          context,
                          participant.id,
                          participant.points,
                          setSheetState,
                        ),
                        icon: const Icon(Icons.add_chart_rounded),
                        label: const Text('Ajustar puntos'),
                      ),
                    ),
                    if (missingCommunity != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () => _confirmCommunitySignal(
                            context,
                            participant.id,
                            setSheetState,
                          ),
                          icon: const Icon(Icons.groups_rounded),
                          label: const Text('Validar Community Signal'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final treasure in missing)
                          if (treasure.id != 'gym-community')
                            OutlinedButton(
                              onPressed: () async {
                                final result = await controller.grantMedal(
                                  participantId: participant.id,
                                  gymId: treasure.id,
                                );
                                if (context.mounted &&
                                    result != StaffActionResult.success) {
                                  showSnack(
                                    context,
                                    _staffResultMessage(result),
                                  );
                                }
                                setSheetState(() {});
                              },
                              child: Text(
                                'Otorgar ${_adminGymLabel(treasure.track, treasure.gymName ?? treasure.title)}',
                              ),
                            ),
                      ],
                    ),
                    if (missing.isEmpty)
                      const Text(
                        'Todas las medallas fueron otorgadas.',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showPointAdjustmentDialog(
    BuildContext context,
    String participantId,
    int currentPoints,
    StateSetter setSheetState,
  ) async {
    String? error;
    String rawDelta = '';
    int delta = 0;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final newTotal = (currentPoints + delta).clamp(0, 1 << 31);
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Ajustar puntos',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Puntos actuales: $currentPoints',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('admin-points-delta'),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Ajuste (+/-)',
                    errorText: error,
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      error = null;
                      rawDelta = value.trim();
                      delta = int.tryParse(value.trim()) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Nuevo total: $newTotal',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final parsed = int.tryParse(rawDelta);
                  if (parsed == null) {
                    setDialogState(() {
                      error = 'Introduce un numero entero';
                    });
                    return;
                  }
                  try {
                    final ok = await AppScope.read(context)
                        .adjustParticipantPoints(
                          participantId: participantId,
                          delta: parsed,
                        );
                    if (!context.mounted) return;
                    showSnack(
                      context,
                      ok
                          ? 'Puntos actualizados'
                          : 'No se pudo actualizar: participante no encontrado',
                    );
                  } catch (_) {
                    if (context.mounted) showNetworkError(context);
                  } finally {
                    setSheetState(() {});
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  }
                },
                child: const Text('Aplicar ajuste'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmCommunitySignal(
    BuildContext context,
    String participantId,
    StateSetter setSheetState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Validar Community Signal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Confirma que staff reviso la evidencia y otorgara la medalla Comunidad.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Validar evidencia'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;
    final result = await AppScope.read(
      context,
    ).grantMedal(participantId: participantId, gymId: 'gym-community');
    if (context.mounted && result != StaffActionResult.success) {
      showSnack(context, _staffResultMessage(result));
    }
    setSheetState(() {});
  }

  String _staffResultMessage(StaffActionResult result) {
    switch (result) {
      case StaffActionResult.success:
        return 'Medalla otorgada';
      case StaffActionResult.participantNotFound:
        return 'No se pudo otorgar: participante no encontrado';
      case StaffActionResult.gymNotFound:
        return 'No se pudo otorgar: gimnasio no encontrado';
      case StaffActionResult.gymInactive:
        return 'No se pudo otorgar: gimnasio inactivo';
      case StaffActionResult.alreadyGranted:
        return 'La medalla ya estaba otorgada';
    }
  }

  String _adminGymLabel(String? track, String fallback) {
    switch (track) {
      case 'android':
        return 'Android';
      case 'ia':
        return 'IA';
      case 'security':
        return 'Security';
      case 'web':
        return 'Web';
      case 'startup':
        return 'Startup';
      case 'cloud':
        return 'Cloud';
      case 'speaker':
        return 'Speaker';
      case 'community':
        return 'Community';
    }
    return fallback;
  }
}
