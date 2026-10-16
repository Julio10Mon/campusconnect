import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/motion.dart';
import 'events_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'notices_screen.dart';
import 'profile_screen.dart';

/// Navegación principal
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final screens = [
      HomeScreen(onSeeEvents: () => setState(() => _index = 2), onSeeNotices: () => setState(() => _index = 1)),
      const NoticesScreen(),
      const EventsScreen(),
      const ExploreScreen(),
      const ProfileScreen(),
    ];

    const destinations = [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: AppStrings.navHome),
      NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign_rounded), label: AppStrings.navNotices),
      NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event_rounded), label: AppStrings.navEvents),
      NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: AppStrings.navExplore),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: AppStrings.navProfile),
    ];

    // Índice válido
    final safeIndex = _index < screens.length ? _index : 0;

    return Scaffold(
      body: FadeOnChange(token: safeIndex, child: IndexedStack(index: safeIndex, children: screens)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outline)),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: destinations,
        ),
      ),
    );
  }
}
