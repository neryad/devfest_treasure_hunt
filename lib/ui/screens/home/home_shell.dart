import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../admin_navigation.dart';
import '../discovery/manual_code_screen.dart';
import '../information/information_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../results/final_results_screen.dart';
import 'home_dashboard.dart';

/// Main shell for a participant with bottom navigation:
/// DevMaster · Ranking · Finalistas, plus a highlighted CTA for gym codes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['DevMaster', 'Ranking', 'Resultados finales'];

  void _openFindSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Encuentra un Gimnasio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.keyboard_rounded, color: Colors.white),
              ),
              title: const Text('Introducir código del Gimnasio'),
              subtitle: const Text('Escribe el código manual'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManualCodeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_index]),
          actions: [
            IconButton(
              tooltip: 'Información y reglas',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InformationScreen(),
                ),
              ),
              icon: const Icon(Icons.info_outline_rounded),
            ),
            IconButton(
              tooltip: 'Panel Staff',
              onPressed: () => openAdminDemo(context),
              icon: const Icon(Icons.admin_panel_settings_rounded),
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: const [
            HomeDashboard(),
            LeaderboardScreen(),
            FinalResultsScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_rounded),
              label: 'DevMaster',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: 'Finalistas',
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openFindSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.search_rounded),
          label: const Text('Introducir código'),
        ),
      ),
    );
  }
}
