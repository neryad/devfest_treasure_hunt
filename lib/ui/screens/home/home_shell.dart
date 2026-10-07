import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../admin_navigation.dart';
import '../discovery/manual_code_screen.dart';
import '../discovery/qr_scanner_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../pokedex/pokedex_screen.dart';
import 'home_dashboard.dart';

/// Main shell for a participant with bottom navigation:
/// Inicio · DevDex · Ranking, plus a highlighted CTA to scan or enter a gym code.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Inicio', 'DevDex · Gimnasios', 'Ranking'];

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
                backgroundColor: AppColors.primary,
                child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              ),
              title: const Text('Escanear QR del Gimnasio'),
              subtitle: const Text('Usa la cámara o el modo demo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const QrScannerScreen(),
                  ),
                );
              },
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
              tooltip: 'Panel admin demo',
              onPressed: () => openAdminDemo(context),
              icon: const Icon(Icons.admin_panel_settings_rounded),
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: const [
            HomeDashboard(),
            PokedexScreen(),
            LeaderboardScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_rounded),
              label: 'DevDex',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'Ranking',
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openFindSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.search_rounded),
          label: const Text('Escanear QR'),
        ),
      ),
    );
  }
}
