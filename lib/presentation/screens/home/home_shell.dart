import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_nav_bar.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSeeEvents: () => setState(() => _index = 2),
        onSeeNotices: () => setState(() => _index = 1),
        onSeeExplore: () => setState(() => _index = 3),
        onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      const NoticesScreen(),
      const EventsScreen(),
      const ExploreScreen(),
      const ProfileScreen(),
    ];

    const destinations = [
      AppNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: AppStrings.navHome),
      AppNavItem(icon: Icons.campaign_outlined, selectedIcon: Icons.campaign_rounded, label: AppStrings.navNotices),
      AppNavItem(icon: Icons.event_outlined, selectedIcon: Icons.event_rounded, label: AppStrings.navEvents),
      AppNavItem(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: AppStrings.navExplore),
      AppNavItem(icon: Icons.person_outline, selectedIcon: Icons.person_rounded, label: AppStrings.navProfile),
    ];

    // Índice válido
    final safeIndex = _index < screens.length ? _index : 0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        selectedIndex: safeIndex,
        items: destinations,
        onSelected: (i) => setState(() => _index = i),
      ),
      body: FadeOnChange(token: safeIndex, child: IndexedStack(index: safeIndex, children: screens)),
      bottomNavigationBar: AppNavBar(
        selectedIndex: safeIndex,
        onSelected: (i) => setState(() => _index = i),
        items: destinations,
      ),
    );
  }
}
