import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';

/// "Mis tesoros": everything split into found vs pending.
/// Pending treasures never spoil their description or location; they only
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
          'Encontrados',
          style: _sectionStyle,
        ),
        if (found.isEmpty) _EmptyFoundCard(),
        for (final t in found) _TreasureTile(treasure: t, revealed: true),
        const SizedBox(height: 20),
        Text('Pendientes', style: _sectionStyle),
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
        '$found encontrados · $pending pendientes · $total total',
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
        title: Text(
          revealed ? treasure.title : 'Tesoro #${treasure.order.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: revealed
            ? Text(
                treasure.locationDescription,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              )
            : const Text(
                '???',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
        trailing: revealed
            ? null
            : (treasure.isActive
                ? const StatusPill(label: 'Disponible', color: AppColors.secondary)
                : const StatusPill(
                    label: 'No disponible',
                    color: AppColors.danger,
                    icon: Icons.lock_rounded,
                  )),
      ),
    );
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