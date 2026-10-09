import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StartupMiniGame extends StatefulWidget {
  const StartupMiniGame({
    super.key,
    required this.targetScore,
    required this.onCompleted,
    this.initialRunway = 100,
    this.random,
  });

  final int targetScore;
  final VoidCallback onCompleted;
  final int initialRunway;
  final Random? random;

  @override
  State<StartupMiniGame> createState() => _StartupMiniGameState();
}

class _StartupMiniGameState extends State<StartupMiniGame>
    with TickerProviderStateMixin {
  static const _pointsPerHit = 10;
  static const _runwayPenalty = 20;
  static const _initialEnemyDuration = 4500;
  static const _enemySpeedStep = 500;
  static const _threats = ['BUG', 'CHURN', 'OUTAGE', 'NO CASH'];

  late final AnimationController _enemyController;
  late final AnimationController _projectileController;
  late final Random _random;
  int _shipLane = 1;
  List<_StartupEnemy> _enemies = [];
  int? _projectileLane;
  int? _projectileTargetId;
  int _nextEnemyId = 0;
  int _nextThreatIndex = 0;
  int _score = 0;
  late int _runway;
  bool _completed = false;
  bool _gameOver = false;
  String? _feedback;

  bool get _isAligned => _enemies.any((enemy) => enemy.lane == _shipLane);
  int get _targetHits => (widget.targetScore / _pointsPerHit).ceil();
  int get _validatedHits => (_score / _pointsPerHit).ceil();
  _StartupEnemy? get _projectileTarget {
    final targetId = _projectileTargetId;
    if (targetId == null) return null;
    for (final enemy in _enemies) {
      if (enemy.id == targetId) return enemy;
    }
    return null;
  }

  String get _guidance {
    if (_projectileController.isAnimating) return 'MVP en camino…';
    if (_isAligned) return '¡Objetivo alineado! Dispara tu MVP';
    if (_enemies.isEmpty) return '¡MVP validado!';
    final enemyLanes = _enemies.map((enemy) => enemy.lane).toSet();
    final nearestEnemyLane = enemyLanes.reduce(
      (current, lane) => (lane - _shipLane).abs() < (current - _shipLane).abs()
          ? lane
          : current,
    );
    return nearestEnemyLane < _shipLane
        ? 'Muévete a la izquierda para alinear el objetivo'
        : 'Muévete a la derecha para alinear el objetivo';
  }

  Color get _runwayColor {
    final ratio = _runway / widget.initialRunway;
    if (ratio <= 0.4) return AppColors.danger;
    if (ratio <= 0.7) return AppColors.amber;
    return AppColors.success;
  }

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _spawnWave();
    _runway = widget.initialRunway;
    _enemyController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: _initialEnemyDuration),
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
    setState(() {
      _shipLane = (_shipLane - 1).clamp(0, 2);
      _feedback = null;
    });
  }

  void _moveRight() {
    if (_gameOver || _completed) return;
    setState(() {
      _shipLane = (_shipLane + 1).clamp(0, 2);
      _feedback = null;
    });
  }

  void _fire() {
    if (_gameOver ||
        _completed ||
        !_isAligned ||
        _projectileController.isAnimating) {
      return;
    }
    final target = _targetForLane(_shipLane);
    if (target == null) return;
    setState(() {
      _projectileLane = _shipLane;
      _projectileTargetId = target.id;
      _feedback = null;
    });
    _projectileController.forward(from: 0);
  }

  void _resolveShot() {
    if (_gameOver || _completed) return;
    final shotLane = _projectileLane;
    final targetId = _projectileTargetId;
    final hit =
        targetId != null &&
        _enemies.any((enemy) => enemy.id == targetId && enemy.lane == shotLane);
    setState(() {
      _projectileLane = null;
      _projectileTargetId = null;
    });

    if (!hit) {
      _missEnemy();
      return;
    }

    final clearsWave = _enemies.length == 1;
    setState(() {
      _enemies.removeWhere((enemy) => enemy.id == targetId);
      _score = (_score + _pointsPerHit).clamp(0, widget.targetScore);
      _feedback = '¡Impacto! +$_pointsPerHit de validación';
      if (clearsWave && _score < widget.targetScore) _spawnWave();
    });

    if (_score >= widget.targetScore) {
      _completed = true;
      _enemyController.stop();
      widget.onCompleted();
      return;
    }
    if (clearsWave) _restartEnemy();
  }

  void _missEnemy() {
    if (_gameOver || _completed) return;
    if (_projectileController.isAnimating) {
      _projectileController
        ..stop()
        ..reset();
    }
    setState(() {
      _projectileLane = null;
      _projectileTargetId = null;
      _runway = (_runway - _runwayPenalty).clamp(0, widget.initialRunway);
      _feedback = 'La amenaza llegó: -$_runwayPenalty de runway';
      _gameOver = _runway == 0;
      if (!_gameOver) _spawnWave();
    });
    if (_gameOver) {
      _enemyController.stop();
      return;
    }
    _restartEnemy();
  }

  _StartupEnemy? _targetForLane(int lane) {
    final targets = _enemies.where((enemy) => enemy.lane == lane);
    if (targets.isEmpty) return null;
    return targets.reduce(
      (closest, enemy) =>
          enemy.stackIndex > closest.stackIndex ? enemy : closest,
    );
  }

  void _spawnWave() {
    final enemyCount = 1 + _random.nextInt(5);
    final laneCounts = [0, 0, 0];
    final enemies = <_StartupEnemy>[];

    for (var index = 0; index < enemyCount; index++) {
      final availableLanes = [
        for (var lane = 0; lane < 3; lane++)
          if (laneCounts[lane] < 2) lane,
      ];
      final lane = availableLanes[_random.nextInt(availableLanes.length)];
      enemies.add(
        _StartupEnemy(
          id: _nextEnemyId++,
          lane: lane,
          stackIndex: laneCounts[lane]++,
          threat: _threats[_nextThreatIndex++ % _threats.length],
        ),
      );
    }
    _enemies = enemies;
  }

  void _retry() {
    setState(() {
      _shipLane = 1;
      _nextEnemyId = 0;
      _nextThreatIndex = 0;
      _spawnWave();
      _projectileLane = null;
      _projectileTargetId = null;
      _score = 0;
      _runway = widget.initialRunway;
      _completed = false;
      _gameOver = false;
      _feedback = null;
    });
    _restartEnemy();
  }

  void _restartEnemy() {
    final speedLevel = (_score ~/ 30).clamp(0, 2);
    _enemyController.duration = Duration(
      milliseconds: _initialEnemyDuration - (speedLevel * _enemySpeedStep),
    );
    _enemyController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_score / widget.targetScore).clamp(0.0, 1.0);
    final runwayProgress = (_runway / widget.initialRunway).clamp(0.0, 1.0);
    final canFire = _isAligned && !_projectileController.isAnimating;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // HUD
              Row(
                children: [
                  Expanded(
                    child: _Meter(
                      icon: Icons.flag_rounded,
                      label: '$_validatedHits/$_targetHits',
                      value: progress,
                      color: AppColors.primarySoft,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _Meter(
                      icon: Icons.local_fire_department_rounded,
                      label: '$_runway',
                      value: runwayProgress,
                      color: _runwayColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Campo de juego (ocupa todo el espacio libre)
              Expanded(
                child: Stack(
                  children: [
                    _Battlefield(
                      shipLane: _shipLane,
                      enemies: _enemies,
                      enemyProgress: _enemyController,
                      projectileLane: _projectileLane,
                      projectileTarget: _projectileTarget,
                      projectileProgress: _projectileController,
                      onLaneTap: (lane) {
                        if (_gameOver || _completed) return;
                        setState(() {
                          _shipLane = lane;
                          _feedback = null;
                        });
                      },
                    ),
                    if (_gameOver)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_rounded,
                                color: AppColors.danger,
                                size: 56,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Te quedaste sin runway',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Validaste $_validatedHits de $_targetHits MVPs',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _retry,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Mensaje de una sola línea
              SizedBox(
                height: 36,
                child: Center(
                  child: Text(
                    _feedback ?? _guidance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _feedback == null
                          ? (_isAligned
                                ? AppColors.successSoft
                                : AppColors.textSecondary)
                          : (_feedback!.startsWith('¡')
                                ? AppColors.successSoft
                                : AppColors.dangerSoft),
                    ),
                  ),
                ),
              ),

              // Controles grandes
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Mover startup a la izquierda',
                      button: true,
                      child: OutlinedButton(
                        key: const Key('startup-game-move-left'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _shipLane > 0 && !_gameOver
                            ? _moveLeft
                            : null,
                        child: const Icon(Icons.arrow_back_rounded, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      key: const Key('startup-game-fire'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: canFire && !_gameOver ? _fire : null,
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text(
                        'DISPARAR',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      label: 'Mover startup a la derecha',
                      button: true,
                      child: OutlinedButton(
                        key: const Key('startup-game-move-right'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _shipLane < 2 && !_gameOver
                            ? _moveRight
                            : null,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 28,
                        ),
                      ),
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
          ),
        ),
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _Battlefield extends StatelessWidget {
  const _Battlefield({
    required this.shipLane,
    required this.enemies,
    required this.enemyProgress,
    required this.projectileLane,
    required this.projectileTarget,
    required this.projectileProgress,
    required this.onLaneTap,
  });

  final int shipLane;
  final List<_StartupEnemy> enemies;
  final Animation<double> enemyProgress;
  final int? projectileLane;
  final _StartupEnemy? projectileTarget;
  final Animation<double> projectileProgress;
  final ValueChanged<int> onLaneTap;

  static const _shipSize = 52.0;
  static const _shipBottom = 14.0;
  static const _enemyHeight = 34.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.primary.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: AppColors.surfaceAlt),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            const enemyMinTop = 12.0;
            final enemyMaxTop = h - _shipBottom - _shipSize - _enemyHeight - 8;
            final shipTop = h - _shipBottom - _shipSize;

            return Row(
              children: List.generate(3, (lane) {
                final isShipLane = shipLane == lane;
                final laneEnemies = enemies
                    .where((enemy) => enemy.lane == lane)
                    .toList();
                final lastStackIndex = laneEnemies.fold<int>(
                  0,
                  (highest, enemy) => max(highest, enemy.stackIndex),
                );

                double enemyTop(int stackIndex) {
                  final startTop = enemyMinTop + (stackIndex * 48);
                  final lastEnemyStart = enemyMinTop + (lastStackIndex * 48);
                  final travelDistance = max(0.0, enemyMaxTop - lastEnemyStart);
                  return startTop + travelDistance * enemyProgress.value;
                }

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onLaneTap(lane),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isShipLane
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withValues(alpha: 0.12),
                                ],
                              )
                            : null,
                        border: Border(
                          right: lane == 2
                              ? BorderSide.none
                              : BorderSide(
                                  color: AppColors.surfaceAlt.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Rayo guía cuando está alineado
                          if (isShipLane &&
                              enemies.any((enemy) => enemy.lane == lane))
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 2,
                                  color: AppColors.success.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                            ),

                          // Enemigo
                          for (final enemy in laneEnemies)
                            AnimatedBuilder(
                              animation: enemyProgress,
                              builder: (context, child) => Positioned(
                                left: 0,
                                right: 0,
                                top: enemyTop(enemy.stackIndex),
                                child: Center(child: child),
                              ),
                              child: _EnemyChip(enemy: enemy),
                            ),

                          // Proyectil (viaja hasta el enemigo)
                          if (projectileLane == lane)
                            AnimatedBuilder(
                              animation: projectileProgress,
                              builder: (context, child) {
                                final from = shipTop - 20;
                                final to =
                                    enemyTop(
                                      projectileTarget?.stackIndex ?? 0,
                                    ) +
                                    10;
                                return Positioned(
                                  left: 0,
                                  right: 0,
                                  top:
                                      from +
                                      (to - from) * projectileProgress.value,
                                  child: Center(child: child),
                                );
                              },
                              child: const _Projectile(),
                            ),

                          // Nave
                          if (isShipLane)
                            const Positioned(
                              left: 0,
                              right: 0,
                              bottom: _shipBottom,
                              child: Center(
                                child: Icon(
                                  Icons.rocket_launch_rounded,
                                  color: AppColors.primarySoft,
                                  size: _shipSize,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
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
      width: 8,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.7),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _EnemyChip extends StatelessWidget {
  const _EnemyChip({required this.enemy});

  final _StartupEnemy enemy;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('startup-game-enemy-${enemy.lane}-${enemy.id}'),
      height: _Battlefield._enemyHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.35),
            blurRadius: 14,
          ),
        ],
      ),
      child: Text(
        enemy.threat,
        maxLines: 1,
        style: const TextStyle(
          color: AppColors.dangerSoft,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StartupEnemy {
  const _StartupEnemy({
    required this.id,
    required this.lane,
    required this.stackIndex,
    required this.threat,
  });

  final int id;
  final int lane;
  final int stackIndex;
  final String threat;
}
