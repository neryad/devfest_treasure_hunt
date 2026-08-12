import 'package:flutter/material.dart';

/// Maps a treasure's `iconKey` to an [IconData]. UI-only concern.
IconData treasureIconForKey(String key) {
  switch (key) {
    case 'badge':
      return Icons.workspace_premium_rounded;
    case 'mic':
      return Icons.mic_rounded;
    case 'coffee':
      return Icons.coffee_rounded;
    case 'rocket':
      return Icons.rocket_launch_rounded;
    case 'code':
      return Icons.code_rounded;
    case 'cpu':
      return Icons.memory_rounded;
    case 'people':
      return Icons.groups_rounded;
    case 'laptop':
      return Icons.laptop_mac_rounded;
    case 'gift':
      return Icons.card_giftcard_rounded;
    case 'trophy':
      return Icons.emoji_events_rounded;
    default:
      return Icons.explore_rounded;
  }
}