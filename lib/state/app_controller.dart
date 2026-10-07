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
import '../domain/repositories/attempt_repository.dart';
import '../domain/repositories/treasure_repository.dart';
import '../domain/use_cases/complete_challenge_use_case.dart';
import '../domain/use_cases/discover_treasure_use_case.dart';
import '../domain/use_cases/leaderboard_use_case.dart';
import '../domain/use_cases/start_participant_use_case.dart';

const _cooldownDuration = Duration(minutes: 5);
const _adminUser = 'admin';
const _adminPassword = 'devfest2026';

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
    AttemptRepository? attemptRepository,
    this.enableElapsedTicker = true,
    this.offline = false,
  }) : _treasureRepository = treasureRepository,
       _participantRepository = participantRepository {
    _discoverUseCase = DiscoverTreasureUseCase(
      treasureRepository: treasureRepository,
      participantRepository: participantRepository,
    );
    _startUseCase = StartParticipantUseCase(participantRepository);
    _leaderboardUseCase = LeaderboardUseCase(leaderboardRepository);
    _eventRepository = eventRepository;
    _resetStore = resetStore;
    _completeChallengeUseCase = attemptRepository != null
        ? CompleteChallengeUseCase(
            treasureRepository: treasureRepository,
            participantRepository: participantRepository,
            attemptRepository: attemptRepository,
          )
        : null;
  }

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  late final EventRepository _eventRepository;
  late final Future<void> Function()? _resetStore;
  final bool enableElapsedTicker;

  /// True when the app is running on local (unsynced) data by explicit choice.
  final bool offline;

  late final DiscoverTreasureUseCase _discoverUseCase;
  late final StartParticipantUseCase _startUseCase;
  late final LeaderboardUseCase _leaderboardUseCase;
  late final CompleteChallengeUseCase? _completeChallengeUseCase;

  bool _initializing = true;
  bool _initFailed = false;
  bool _sessionExpired = false;
  Event? _event;
  List<TreasureItem> _treasures = [];
  Participant? _participant;
  List<Participant> _participants = [];
  List<LeaderboardEntry> _leaderboard = [];
  final Set<String> _consultedClues = {};
  Timer? _ticker;
  String? _lastError;
  ChallengeResult? _lastChallengeResult;
  DateTime? _cooldownStart;
  bool _adminSignedIn = false;

  bool get initializing => _initializing;
  bool get initFailed => _initFailed;
  bool get sessionExpired => _sessionExpired;
  Event? get event => _event;
  List<TreasureItem> get treasures => _treasures;
  Participant? get participant => _participant;
  List<Participant> get participants => _participants;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  String? get lastError => _lastError;
  ChallengeResult? get lastChallengeResult => _lastChallengeResult;
  bool get adminSignedIn => _adminSignedIn;

  bool get isOnCooldown {
    final start = _cooldownStart;
    if (start == null) return false;
    return DateTime.now().difference(start) < _cooldownDuration;
  }

  Duration get cooldownRemaining {
    final start = _cooldownStart;
    if (start == null) return Duration.zero;
    final elapsed = DateTime.now().difference(start);
    final remaining = _cooldownDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

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

  CompleteChallengeUseCase? get completeChallengeUseCase =>
      _completeChallengeUseCase;

  bool signInAdmin(String user, String password) {
    final valid = user.trim() == _adminUser && password == _adminPassword;
    _adminSignedIn = valid;
    notifyListeners();
    return valid;
  }

  void signOutAdmin() {
    _adminSignedIn = false;
    notifyListeners();
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
        .map(
          (t) => Clue(
            treasureId: t.id,
            text: t.clue,
            unlocked: discovered.contains(t.id),
            consulted: _consultedClues.contains(t.id),
          ),
        )
        .toList();
  }

  Future<void> initialize() async {
    _initializing = true;
    _initFailed = false;
    _sessionExpired = false;
    notifyListeners();
    try {
      final id = await _participantRepository.getCurrentParticipantId();
      if (id != null) {
        _participant = await _participantRepository.getParticipant(id);
        if (_participant == null) {
          await _participantRepository.setCurrentParticipantId(null);
          _sessionExpired = true;
        }
      }
      await _reloadStaticData();
      await _reloadLeaderboard();
      _startTickerIfNeeded();
    } catch (_) {
      _initFailed = true;
    }
    _initializing = false;
    notifyListeners();
  }

  Future<void> startParticipant({
    required String name,
    required String nickname,
  }) async {
    _sessionExpired = false;
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
        DiscoverFailure.participantNotFound,
      );
    }
    final treasure = await _treasureRepository.getByCode(code);
    return _runDiscovery(treasure);
  }

  Future<DiscoverTreasureResult> discoverByQrValue(String value) async {
    if (_participant == null) {
      return const DiscoverTreasureResult.failure(
        DiscoverFailure.participantNotFound,
      );
    }
    final treasure = await _treasureRepository.getByQrValue(value);
    return _runDiscovery(treasure);
  }

  Future<DiscoverTreasureResult> discoverByTreasureId(String treasureId) async {
    if (_participant == null) {
      return const DiscoverTreasureResult.failure(
        DiscoverFailure.participantNotFound,
      );
    }
    final treasure = await _treasureRepository.getTreasure(treasureId);
    return _runDiscovery(treasure);
  }

  Future<DiscoverTreasureResult> _runDiscovery(TreasureItem? treasure) async {
    if (treasure == null) {
      return const DiscoverTreasureResult.failure(
        DiscoverFailure.treasureNotFound,
      );
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

  Future<bool> grantMedal({
    required String participantId,
    required String gymId,
  }) async {
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    final gym = await _treasureRepository.getTreasure(gymId);
    if (participant == null || gym == null || !gym.isActive) return false;
    if (participant.discoveredTreasureIds.contains(gymId)) return false;

    final updatedTreasures = [...participant.discoveredTreasureIds, gymId];
    final allTreasures = await _treasureRepository.getTreasures();
    final completed = updatedTreasures.length >= allTreasures.length;
    final updated = participant.copyWith(
      discoveredTreasureIds: updatedTreasures,
      points: participant.points + (gym.challenge?.points ?? gym.pointValue),
      medals: updatedTreasures.length,
      status: completed ? ParticipantStatus.completed : participant.status,
      completedAt: completed ? DateTime.now() : participant.completedAt,
    );

    await _participantRepository.updateParticipant(updated);
    if (_participant?.id == participantId) {
      _participant = updated;
    }
    await _reloadLeaderboard();
    notifyListeners();
    return true;
  }

  Future<bool> adjustParticipantPoints({
    required String participantId,
    required int delta,
  }) async {
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    if (participant == null) return false;

    final updatedPoints = (participant.points + delta).clamp(0, 1 << 31);
    final updated = participant.copyWith(points: updatedPoints);

    await _participantRepository.updateParticipant(updated);
    if (_participant?.id == participantId) {
      _participant = updated;
    }
    await _reloadLeaderboard();
    notifyListeners();
    return true;
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
    _lastChallengeResult = null;
    _cooldownStart = null;
    await _reloadStaticData();
    await _reloadLeaderboard();
    notifyListeners();
  }

  Future<void> submitChallenge(String gymId, String answer) async {
    final participant = _participant;
    if (participant == null || _completeChallengeUseCase == null) return;
    final result = await _completeChallengeUseCase.execute(
      participantId: participant.id,
      gymId: gymId,
      answer: answer,
    );
    _lastChallengeResult = result;
    if (!result.isSuccess && result.cooldownRemaining != null) {
      _cooldownStart = DateTime.now();
    }
    if (result.isSuccess) {
      _participant = _participant?.copyWith(
        discoveredTreasureIds: [
          ...(_participant?.discoveredTreasureIds ?? []),
          gymId,
        ],
        points: result.totalPoints ?? _participant?.points ?? 0,
        medals: result.medals ?? _participant?.medals ?? 0,
      );
      await _reloadLeaderboard();
    }
    notifyListeners();
  }

  void clearChallengeResult() {
    _lastChallengeResult = null;
    _cooldownStart = null;
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
