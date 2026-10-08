import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class PixelPerfectMiniGame extends StatefulWidget {
  const PixelPerfectMiniGame({
    super.key,
    required this.targetScore,
    required this.onCompleted,
    this.initialRunway = 100,
    this.random,
  });

  final int targetScore;
  final VoidCallback onCompleted;
  final int initialRunway;

  /// Injectable only to make the generated rounds deterministic in tests.
  final Random? random;

  @override
  State<PixelPerfectMiniGame> createState() => _PixelPerfectMiniGameState();
}

enum _Phase { memorize, choose, reveal }

class _PixelPerfectMiniGameState extends State<PixelPerfectMiniGame>
    with SingleTickerProviderStateMixin {
  static const _pointsPerHit = 10;
  static const _runwayPenalty = 20;
  static const _tileCount = 16;
  static const _columns = 4;

  late final Random _rng;
  late final AnimationController _memorizeController;
  Timer? _revealTimer;

  _Phase _phase = _Phase.memorize;
  Color _target = Colors.transparent;
  List<Color> _tiles = const [];
  int _targetIndex = 0;
  int? _picked;
  int _round = 0;
  int _score = 0;
  late int _runway;
  bool _completed = false;
  bool _gameOver = false;
  String? _feedback;

  int get _targetHits => (widget.targetScore / _pointsPerHit).ceil();
  int get _validatedHits => (_score / _pointsPerHit).ceil();

  double get _spread {
    final difficulty = (_round / 10).clamp(0.0, 1.0);
    return 0.14 - (0.12 * difficulty);
  }

  Duration get _memorizeDuration {
    final milliseconds = (2400 - _round * 120).clamp(1200, 2400).toInt();
    return Duration(milliseconds: milliseconds);
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
    _rng = widget.random ?? Random();
    _runway = widget.initialRunway;
    _memorizeController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _phase == _Phase.memorize) {
          setState(() => _phase = _Phase.choose);
        }
      });
    _prepareRound();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _memorizeController.dispose();
    super.dispose();
  }

  void _prepareRound() {
    final base = HSLColor.fromAHSL(
      1,
      _rng.nextDouble() * 360,
      0.4 + _rng.nextDouble() * 0.5,
      0.3 + _rng.nextDouble() * 0.4,
    );

    _targetIndex = _rng.nextInt(_tileCount);
    _tiles = List<Color>.generate(
      _tileCount,
      (index) => index == _targetIndex ? base.toColor() : _decoy(base, _spread),
    );
    _target = base.toColor();
    _picked = null;
    _feedback = null;
    _phase = _Phase.memorize;

    _memorizeController.duration = _memorizeDuration;
    _memorizeController.forward(from: 0);
  }

  Color _decoy(HSLColor base, double spread) {
    double offset() {
      final magnitude = spread * (0.5 + _rng.nextDouble() * 0.5);
      return _rng.nextBool() ? magnitude : -magnitude;
    }

    return HSLColor.fromAHSL(
      1,
      (base.hue + offset() * 120) % 360,
      (base.saturation + offset()).clamp(0.0, 1.0),
      (base.lightness + offset()).clamp(0.0, 1.0),
    ).toColor();
  }

  void _pick(int index) {
    if (_phase != _Phase.choose || _gameOver || _completed) return;
    final correct = index == _targetIndex;

    setState(() {
      _picked = index;
      _phase = _Phase.reveal;
      _round += 1;
      if (correct) {
        _score = (_score + _pointsPerHit).clamp(0, widget.targetScore);
        _feedback = '¡Exacto! +$_pointsPerHit de validación';
      } else {
        _runway = (_runway - _runwayPenalty).clamp(0, widget.initialRunway);
        _feedback = 'Ese tono no era: -$_runwayPenalty de runway';
        _gameOver = _runway == 0;
      }
    });

    if (_score >= widget.targetScore) {
      _completed = true;
      widget.onCompleted();
      return;
    }
    if (_gameOver) return;

    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(_prepareRound);
    });
  }

  void _retry() {
    _revealTimer?.cancel();
    setState(() {
      _score = 0;
      _round = 0;
      _runway = widget.initialRunway;
      _completed = false;
      _gameOver = false;
      _prepareRound();
    });
  }

  String get _guidance => switch (_phase) {
    _Phase.memorize => 'Memoriza el color exacto…',
    _Phase.choose => '¿Qué tono coincide con el original?',
    _Phase.reveal => _feedback ?? '',
  };

  @override
  Widget build(BuildContext context) {
    final progress = (_score / widget.targetScore).clamp(0.0, 1.0);
    final runwayProgress = (_runway / widget.initialRunway).clamp(0.0, 1.0);
    final isReveal = _phase == _Phase.reveal;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              const Text(
                'Memoriza el color y encuentra el tono idéntico.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Meter(
                      icon: Icons.palette_outlined,
                      label: '$_validatedHits/$_targetHits',
                      value: progress,
                      color: AppColors.primarySoft,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _Meter(
                      icon: Icons.favorite_rounded,
                      label: '$_runway',
                      value: runwayProgress,
                      color: _runwayColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _phase == _Phase.memorize
                          ? _MemorizeView(
                              color: _target,
                              progress: _memorizeController,
                            )
                          : _TileGrid(
                              tiles: _tiles,
                              columns: _columns,
                              enabled: _phase == _Phase.choose,
                              picked: _picked,
                              targetIndex: _targetIndex,
                              revealed: isReveal,
                              onTap: _pick,
                            ),
                    ),
                    if (_gameOver)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.94),
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
                                'Identificaste $_validatedHits de $_targetHits colores',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                key: const Key('pixel-game-retry'),
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
              SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    _guidance,
                    key: const Key('pixel-game-guidance'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isReveal
                          ? (_picked == _targetIndex
                                ? AppColors.successSoft
                                : AppColors.dangerSoft)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemorizeView extends StatelessWidget {
  const _MemorizeView({required this.color, required this.progress});

  final Color color;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('pixel-game-memorize'),
      children: [
        Expanded(
          child: Semantics(
            label: 'Color que debes memorizar',
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: progress,
          builder: (context, _) => ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 1 - progress.value,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.primarySoft),
            ),
          ),
        ),
      ],
    );
  }
}

class _TileGrid extends StatelessWidget {
  const _TileGrid({
    required this.tiles,
    required this.columns,
    required this.enabled,
    required this.picked,
    required this.targetIndex,
    required this.revealed,
    required this.onTap,
  });

  final List<Color> tiles;
  final int columns;
  final bool enabled;
  final int? picked;
  final int targetIndex;
  final bool revealed;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final rows = (tiles.length / columns).ceil();

    return Column(
      key: const Key('pixel-game-grid'),
      children: List.generate(rows, (row) {
        return Expanded(
          child: Row(
            children: List.generate(columns, (column) {
              final index = row * columns + column;
              if (index >= tiles.length) {
                return const Expanded(child: SizedBox());
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: _Tile(
                    index: index,
                    color: tiles[index],
                    onTap: enabled ? () => onTap(index) : null,
                    borderColor: _borderFor(index),
                    borderWidth: _borderWidthFor(index),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Color? _borderFor(int index) {
    if (picked == index) {
      return picked == targetIndex ? AppColors.success : AppColors.danger;
    }
    if (revealed && index == targetIndex) return AppColors.textPrimary;
    return null;
  }

  double _borderWidthFor(int index) {
    if (picked == index) return 4;
    if (revealed && index == targetIndex) return 3;
    return 0;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.index,
    required this.color,
    required this.onTap,
    required this.borderColor,
    required this.borderWidth,
  });

  final int index;
  final Color color;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tono ${index + 1}',
      enabled: onTap != null,
      child: GestureDetector(
        key: Key('pixel-game-tile-$index'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: borderWidth),
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
