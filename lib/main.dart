import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/account_screen.dart';
import 'screens/keyword_screen.dart';
import 'screens/competitor_keywords_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/settings_screen.dart';

final appState = AppState();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Arka planda giriş yapmayı başlat (UI'yı bloklamaz).
  appState.init();
  runApp(const AppfiguresApp());
}

class AppfiguresApp extends StatelessWidget {
  const AppfiguresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appfigures',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CDF),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CDF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _destinations = const [
    (icon: Icons.account_circle_outlined, sel: Icons.account_circle, label: 'Hesap'),
    (icon: Icons.search_outlined, sel: Icons.search, label: 'Keyword'),
    (icon: Icons.groups_outlined, sel: Icons.groups, label: 'Rakip Keyword'),
    (icon: Icons.reviews_outlined, sel: Icons.reviews, label: 'Yorumlar'),
    (icon: Icons.settings_outlined, sel: Icons.settings, label: 'Ayarlar'),
  ];

  Widget _page(int i) {
    switch (i) {
      case 0:
        return const AccountScreen();
      case 1:
        return const KeywordScreen();
      case 2:
        return const CompetitorKeywordsScreen();
      case 3:
        return const ReviewsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const AccountScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.bar_chart_rounded, color: scheme.primary, size: 32),
                  const SizedBox(height: 4),
                  Text('appfigures',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: scheme.primary)),
                  // Canlı giriş durumu rozeti.
                  AnimatedBuilder(
                    animation: appState,
                    builder: (_, _) {
                      Color c;
                      String t;
                      if (appState.loggingIn) {
                        c = Colors.orange;
                        t = 'giriş...';
                      } else if (appState.account != null) {
                        c = Colors.green;
                        t = 'bağlı';
                      } else {
                        c = Colors.red;
                        t = 'hata';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: c),
                            const SizedBox(width: 4),
                            Text(t, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.sel),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _page(_index)),
        ],
      ),
    );
  }
}
