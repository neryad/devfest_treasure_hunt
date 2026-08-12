import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/treasure_progress_bar.dart';
import '../../../state/app_scope.dart';
import '../clues/clues_screen.dart';
import '../completion/completion_screen.dart';
import '../discovery/manual_code_screen.dart';
import '../discovery/qr_scanner_screen.dart';

/// "Inicio" tab: the participant's adventure overview.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final participant = controller.participant;
    if (participant == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final percent = (controller.progress * 100).round();
    final remaining = controller.remaining;
    final position = controller.approximateRank;
    final clues = controller.buildClues();
    final unlockedClues = clues.where((c) => c.unlocked).length;

    return RefreshIndicator(
      onRefresh: () => Future<void>.value(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          _Greeting(name: participant.name, nickname: participant.nickname),
          const SizedBox(height: 16),
          _ProgressHero(
            found: controller.discoveredCount,
            total: controller.totalTreasures,
            percent: percent,
            remaining: remaining,
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
                  value: position == null
                      ? '—'
                      : '#$position',
                  icon: Icons.leaderboard_rounded,
                  accent: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Restantes',
                  value: '$remaining',
                  icon: Icons.pending_actions_rounded,
                  accent: AppColors.amber,
                ),
              ),
            ],
          ),
          if (participant.isCompleted) ...[
            const SizedBox(height: 16),
            const _CompletedBanner(),
          ],
          const SectionHeader(
            title: 'Acciones rápidas',
            subtitle: 'Descubre tesoros y consulta tus pistas',
          ),
          _ActionCard(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Escanear un QR',
            subtitle: 'Apunta a un tesoro físico',
            color: AppColors.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const QrScannerScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.keyboard_rounded,
            title: 'Introducir código manual',
            subtitle: 'Alternativa al escaneo',
            color: AppColors.secondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ManualCodeScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.tips_and_updates_rounded,
            title: 'Mis pistas',
            subtitle: '$unlockedClues de ${clues.length} desbloqueadas',
            color: AppColors.amber,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CluesScreen()),
            ),
          ),
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

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.found,
    required this.total,
    required this.percent,
    required this.remaining,
  });

  final int found;
  final int total;
  final int percent;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$found / $total encontrados',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TreasureProgressBar(progress: found / total, total: total, height: 12),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.amber,
                  ),
                ),
                const Spacer(),
                Text(
                  remaining == 0
                      ? '¡Todo completado! 🏆'
                      : 'Te faltan $remaining tesoros',
                  style: const TextStyle(
                    fontSize: 13,
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
            const Icon(Icons.emoji_events_rounded,
                color: AppColors.amber, size: 32),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}