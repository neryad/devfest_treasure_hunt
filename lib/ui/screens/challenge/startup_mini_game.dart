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
  String? _feedback;

  String get _currentThreat => _threats[_threatIndex % _threats.length];
  bool get _isAligned => _shipLane == _enemyLane;
  int get _targetHits => (widget.targetScore / _pointsPerHit).ceil();
  int get _validatedHits => (_score / _pointsPerHit).ceil();

  String get _guidance {
    if (_projectileController.isAnimating) return 'MVP en camino…';
    if (_isAligned) return '¡Objetivo alineado! Dispara tu MVP';
    return _enemyLane < _shipLane
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
    setState(() {
      _projectileLane = _shipLane;
      _feedback = null;
    });
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
      _feedback = '¡Impacto! +$_pointsPerHit de validación';
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
      _feedback = 'La amenaza llegó: -$_runwayPenalty de runway';
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
    _enemyLane = (_enemyLane + 1) % 3;
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
      _feedback = null;
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
                      enemyLane: _enemyLane,
                      threat: _currentThreat,
                      aligned: _isAligned,
                      enemyProgress: _enemyController,
                      projectileLane: _projectileLane,
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
    required this.enemyLane,
    required this.threat,
    required this.aligned,
    required this.enemyProgress,
    required this.projectileLane,
    required this.projectileProgress,
    required this.onLaneTap,
  });

  final int shipLane;
  final int enemyLane;
  final String threat;
  final bool aligned;
  final Animation<double> enemyProgress;
  final int? projectileLane;
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

            double enemyTop() =>
                enemyMinTop + (enemyMaxTop - enemyMinTop) * enemyProgress.value;

            return Row(
              children: List.generate(3, (lane) {
                final isShipLane = shipLane == lane;
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
                          if (isShipLane && enemyLane == lane && aligned)
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
                          if (enemyLane == lane)
                            AnimatedBuilder(
                              animation: enemyProgress,
                              builder: (context, child) => Positioned(
                                left: 0,
                                right: 0,
                                top: enemyTop(),
                                child: Center(child: child),
                              ),
                              child: _EnemyChip(threat: threat),
                            ),

                          // Proyectil (viaja hasta el enemigo)
                          if (projectileLane == lane)
                            AnimatedBuilder(
                              animation: projectileProgress,
                              builder: (context, child) {
                                final from = shipTop - 20;
                                final to = enemyTop() + 10;
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
  const _EnemyChip({required this.threat});

  final String threat;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('startup-game-enemy'),
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
        threat,
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
