import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StartupMiniGame extends StatefulWidget {
  const StartupMiniGame({
    super.key,
    required this.targetScore,
    required this.onCompleted,
    this.initialRunway = 100,
  });

  final int targetScore;
  final VoidCallback onCompleted;
  final int initialRunway;

  @override
  State<StartupMiniGame> createState() => _StartupMiniGameState();
}

class _StartupMiniGameState extends State<StartupMiniGame>
    with TickerProviderStateMixin {
  static const _pointsPerHit = 10;
  static const _runwayPenalty = 20;
  static const _lanes = ['Izquierda', 'Centro', 'Derecha'];
  static const _threats = ['BUG', 'CHURN', 'OUTAGE', 'NO CASH'];

  late final AnimationController _enemyController;
  late final AnimationController _projectileController;
  int _shipLane = 1;
  int _enemyLane = 1;
  int? _projectileLane;
  int _threatIndex = 0;
  int _score = 0;
  late int _runway;
  bool _completed = false;
  bool _gameOver = false;

  String get _currentThreat => _threats[_threatIndex % _threats.length];

  @override
  void initState() {
    super.initState();
    _runway = widget.initialRunway;
    _enemyController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed &&
              !_gameOver &&
              !_completed) {
            _missEnemy();
          }
        });
    _projectileController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 560),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _resolveShot();
          }
        });
    _enemyController.forward();
  }

  @override
  void dispose() {
    _enemyController.dispose();
    _projectileController.dispose();
    super.dispose();
  }

  void _moveLeft() {
    if (_gameOver || _completed) return;
    setState(() => _shipLane = (_shipLane - 1).clamp(0, 2));
  }

  void _moveRight() {
    if (_gameOver || _completed) return;
    setState(() => _shipLane = (_shipLane + 1).clamp(0, 2));
  }

  void _fire() {
    if (_gameOver || _completed || _projectileController.isAnimating) return;
    setState(() => _projectileLane = _shipLane);
    _enemyController.stop();
    _projectileController.forward(from: 0);
  }

  void _resolveShot() {
    if (_gameOver || _completed) return;
    final hit = _projectileLane == _enemyLane;
    setState(() => _projectileLane = null);

    if (!hit) {
      _missEnemy();
      return;
    }

    setState(() {
      _score = (_score + _pointsPerHit).clamp(0, widget.targetScore);
      _advanceEnemy();
    });

    if (_score >= widget.targetScore) {
      _completed = true;
      _enemyController.stop();
      widget.onCompleted();
      return;
    }
    _restartEnemy();
  }

  void _missEnemy() {
    if (_gameOver || _completed) return;
    setState(() {
      _runway = (_runway - _runwayPenalty).clamp(0, widget.initialRunway);
      _gameOver = _runway == 0;
      if (!_gameOver) _advanceEnemy();
    });
    if (_gameOver) {
      _enemyController.stop();
      return;
    }
    _restartEnemy();
  }

  void _advanceEnemy() {
    _threatIndex += 1;
    _enemyLane = _threatIndex % 3;
  }

  void _retry() {
    setState(() {
      _shipLane = 1;
      _enemyLane = 1;
      _projectileLane = null;
      _threatIndex = 0;
      _score = 0;
      _runway = widget.initialRunway;
      _completed = false;
      _gameOver = false;
    });
    _restartEnemy();
  }

  void _restartEnemy() {
    final speedLevel = (_score ~/ 30).clamp(0, 2);
    _enemyController.duration = Duration(
      milliseconds: 2600 - (speedLevel * 350),
    );
    _enemyController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_score / widget.targetScore).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceAlt),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              size: 38,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            const Text(
              'MVP Invaders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mueve tu startup, alinea el enemigo y dispara tu MVP.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (_gameOver) ...[
              const Icon(
                Icons.warning_rounded,
                color: AppColors.danger,
                size: 42,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu startup se quedó sin runway',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _retry,
                child: const Text('Reintentar'),
              ),
            ] else ...[
              _Battlefield(
                shipLane: _shipLane,
                enemyLane: _enemyLane,
                threat: _currentThreat,
                enemyProgress: _enemyController,
                projectileLane: _projectileLane,
                projectileProgress: _projectileController,
              ),
              const SizedBox(height: 8),
              Text(
                'Carril: ${_lanes[_shipLane]}',
                style: const TextStyle(
                  color: AppColors.primarySoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('startup-game-move-left'),
                      onPressed: _moveLeft,
                      child: const Text('←'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      key: const Key('startup-game-fire'),
                      onPressed: _fire,
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text('MVP'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('startup-game-move-right'),
                      onPressed: _moveRight,
                      child: const Text('→'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 1,
                height: 1,
                child: TextButton(
                  key: const Key('startup-game-miss-enemy'),
                  onPressed: _missEnemy,
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              'Validación: $_score / ${widget.targetScore}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Runway: $_runway',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Battlefield extends StatelessWidget {
  const _Battlefield({
    required this.shipLane,
    required this.enemyLane,
    required this.threat,
    required this.enemyProgress,
    required this.projectileLane,
    required this.projectileProgress,
  });

  final int shipLane;
  final int enemyLane;
  final String threat;
  final Animation<double> enemyProgress;
  final int? projectileLane;
  final Animation<double> projectileProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(3, (lane) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: lane == 2
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.surfaceAlt),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (enemyLane == lane)
                    AnimatedBuilder(
                      animation: enemyProgress,
                      builder: (context, child) {
                        return Positioned(
                          top: 18 + (82 * enemyProgress.value),
                          child: child!,
                        );
                      },
                      child: _EnemyChip(threat: threat),
                    ),
                  if (shipLane == lane)
                    const Positioned(
                      bottom: 18,
                      child: Icon(
                        Icons.rocket_launch_rounded,
                        color: AppColors.primarySoft,
                        size: 42,
                      ),
                    ),
                  if (projectileLane == lane)
                    AnimatedBuilder(
                      animation: projectileProgress,
                      builder: (context, child) {
                        return Positioned(
                          bottom: 62 + (76 * projectileProgress.value),
                          child: child!,
                        );
                      },
                      child: const _Projectile(),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Projectile extends StatelessWidget {
  const _Projectile();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('startup-game-projectile'),
      width: 10,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.65),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _EnemyChip extends StatelessWidget {
  const _EnemyChip({required this.threat});

  final String threat;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('startup-game-enemy'),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger),
      ),
      child: Text(
        threat,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.dangerSoft,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
