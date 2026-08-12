import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/entities/clue.dart';
import '../domain/entities/event.dart';
import '../domain/entities/leaderboard_entry.dart';
import '../domain/entities/participant.dart';
import '../domain/entities/treasure_item.dart';
import '../domain/repositories/event_repository.dart';
import '../domain/repositories/leaderboard_repository.dart';
import '../domain/repositories/participant_repository.dart';
import '../domain/repositories/treasure_repository.dart';
import '../domain/use_cases/discover_treasure_use_case.dart';
import '../domain/use_cases/leaderboard_use_case.dart';
import '../domain/use_cases/start_participant_use_case.dart';

/// Single state container for the demo.
///
/// Screens read state and call actions here; they never touch repositories
/// or storage directly. Follows a MVVM-ish pattern where this controller is
/// the ViewModel shared by every screen (kept intentionally simple for the
/// MVP).
class AppController extends ChangeNotifier {
  AppController({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required LeaderboardRepository leaderboardRepository,
    required EventRepository eventRepository,
    Future<void> Function()? resetStore,
    this.enableElapsedTicker = true,
  })  : _treasureRepository = treasureRepository,
        _participantRepository = participantRepository {
    _discoverUseCase = DiscoverTreasureUseCase(
      treasureRepository: treasureRepository,
      participantRepository: participantRepository,
    );
    _startUseCase = StartParticipantUseCase(participantRepository);
    _leaderboardUseCase = LeaderboardUseCase(leaderboardRepository);
    _eventRepository = eventRepository;
    _resetStore = resetStore;
  }

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  late final EventRepository _eventRepository;
  late final Future<void> Function()? _resetStore;
  final bool enableElapsedTicker;

  late final DiscoverTreasureUseCase _discoverUseCase;
  late final StartParticipantUseCase _startUseCase;
  late final LeaderboardUseCase _leaderboardUseCase;

  bool _initializing = true;
  Event? _event;
  List<TreasureItem> _treasures = [];
  Participant? _participant;
  List<Participant> _participants = [];
  List<LeaderboardEntry> _leaderboard = [];
  final Set<String> _consultedClues = {};
  Timer? _ticker;
  String? _lastError;

  bool get initializing => _initializing;
  Event? get event => _event;
  List<TreasureItem> get treasures => _treasures;
  Participant? get participant => _participant;
  List<Participant> get participants => _participants;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  String? get lastError => _lastError;

  int get totalTreasures => _treasures.length;
  int get discoveredCount => _participant?.discoveredCount ?? 0;
  int get remaining => totalTreasures - discoveredCount;
  double get progress => totalTreasures == 0
      ? 0
      : (discoveredCount / totalTreasures).clamp(0.0, 1.0);

  bool get hasParticipant => _participant != null;

  Duration get elapsed {
    final participant = _participant;
    if (participant == null) return Duration.zero;
    if (participant.isCompleted) {
      return participant.completedAt!.difference(participant.startedAt);
    }
    return DateTime.now().difference(participant.startedAt);
  }

  int? get approximateRank {
    for (final entry in _leaderboard) {
      if (entry.participantId == _participant?.id) return entry.position;
    }
    return null;
  }

  LeaderboardEntry? get myLeaderboardEntry {
    final id = _participant?.id;
    if (id == null) return null;
    for (final entry in _leaderboard) {
      if (entry.participantId == id) return entry;
    }
    return null;
  }

  TreasureItem? treasureById(String id) {
    for (final t in _treasures) {
      if (t.id == id) return t;
    }
    return null;
  }

  TreasureStatus statusOf(TreasureItem treasure) {
    final list = _participant?.discoveredTreasureIds;
    if (list != null && list.contains(treasure.id)) {
      return TreasureStatus.discovered;
    }
    if (!treasure.isActive) return TreasureStatus.disabled;
    return TreasureStatus.available;
  }

  List<Clue> buildClues() {
    final sorted = List.of(_treasures)
      ..sort((a, b) => a.order.compareTo(b.order));
    final discovered = _participant?.discoveredTreasureIds ?? const [];
    return sorted
        .map((t) => Clue(
              treasureId: t.id,
              text: t.clue,
              unlocked: discovered.contains(t.id),
              consulted: _consultedClues.contains(t.id),
            ))
        .toList();
  }

  Future<void> initialize() async {
    _initializing = true;
    notifyListeners();
    final id = await _participantRepository.getCurrentParticipantId();
    if (id != null) {
      _participant = await _participantRepository.getParticipant(id);
    }
    await _reloadStaticData();
    await _reloadLeaderboard();
    _initializing = false;
    _startTickerIfNeeded();
    notifyListeners();
  }

  Future<void> startParticipant({
    required String name,
    required String nickname,
  }) async {
    _participant = await _startUseCase.execute(name: name, nickname: nickname);
    _consultedClues.clear();
    await _reloadLeaderboard();
    _startTickerIfNeeded();
    notifyListeners();
  }

  /// Entry point used by QR scan and manual code. Resolves to a treasure id
  /// and delegates to the single discovery rule.
  Future<DiscoverTreasureResult> discoverByCode(String code) async {
    if (_participant == null) {
      return const DiscoverTreasureResult.failure(
          DiscoverFailure.participantNotFound);
    }
    final treasure = await _treasureRepository.getByCode(code);
    return _runDiscovery(treasure);
  }

  Future<DiscoverTreasureResult> discoverByQrValue(String value) async {
    if (_participant == null) {
      return const DiscoverTreasureResult.failure(
          DiscoverFailure.participantNotFound);
    }
    final treasure = await _treasureRepository.getByQrValue(value);
    return _runDiscovery(treasure);
  }

  Future<DiscoverTreasureResult> discoverByTreasureId(String treasureId) async {
    if (_participant == null) {
      return const DiscoverTreasureResult.failure(
          DiscoverFailure.participantNotFound);
    }
    final treasure = await _treasureRepository.getTreasure(treasureId);
    return _runDiscovery(treasure);
  }

  Future<DiscoverTreasureResult> _runDiscovery(TreasureItem? treasure) async {
    if (treasure == null) {
      return const DiscoverTreasureResult.failure(
          DiscoverFailure.treasureNotFound);
    }
    final participant = _participant!;
    final result = await _discoverUseCase.execute(
      participantId: participant.id,
      treasureId: treasure.id,
    );
    if (result.isSuccess) {
      _participant = result.participant;
      _consultedClues.add(treasure.id);
      await _reloadLeaderboard();
    }
    notifyListeners();
    return result;
  }

  Future<void> setTreasureActive(String id, bool active) async {
    await _treasureRepository.setTreasureActive(id, active);
    await _reloadStaticData();
    notifyListeners();
  }

  Future<void> resetDemo() async {
    _ticker?.cancel();
    _ticker = null;
    final resetStore = _resetStore;
    if (resetStore != null) {
      await resetStore();
    }
    _participant = null;
    _consultedClues.clear();
    await _reloadStaticData();
    await _reloadLeaderboard();
    notifyListeners();
  }

  Future<void> _reloadStaticData() async {
    _event = await _eventRepository.getEvent();
    _treasures = await _treasureRepository.getTreasures();
  }

  Future<void> _reloadLeaderboard() async {
    _participants = await _participantRepository.getParticipants();
    _leaderboard = await _leaderboardUseCase.execute();
  }

  void _startTickerIfNeeded() {
    _ticker?.cancel();
    _ticker = null;
    if (!enableElapsedTicker) return;
    final participant = _participant;
    if (participant == null || participant.isCompleted) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}