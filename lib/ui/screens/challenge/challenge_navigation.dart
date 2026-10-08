import 'package:flutter/material.dart';

import '../../../core/utils/snack_bar_utils.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';
import 'challenge_screen.dart';

const gymUnavailableMessage =
    'No disponible todavía: este gimnasio está desactivado.';

/// Opens [ChallengeScreen] only when the gym is still active, reading the
/// latest state instead of trusting a possibly stale cached snapshot.
Future<void> openChallenge(BuildContext context, TreasureItem gym) async {
  final app = AppScope.read(context);
  TreasureItem? fresh;
  try {
    fresh = await app.fetchTreasure(gym.id);
  } catch (_) {
    if (context.mounted) showNetworkError(context);
    return;
  }
  if (!context.mounted) return;
  if (fresh == null || !fresh.isActive) {
    showSnack(context, gymUnavailableMessage);
    return;
  }
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => ChallengeScreen(gym: fresh!)));
}
