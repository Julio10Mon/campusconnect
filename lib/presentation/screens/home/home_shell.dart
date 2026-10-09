import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'admin/user_management_screen.dart';
import 'calendar_screen.dart';
import 'events_screen.dart';
import 'map_screen.dart';
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
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = userAsync.maybeWhen(data: (u) => u.rol == UserRole.admin, orElse: () => false);

    final screens = [
      const NoticesScreen(),
      const MapScreen(),
      const CalendarScreen(),
      const EventsScreen(),
      if (isAdmin) const UserManagementScreen(),
      const ProfileScreen(),
    ];

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign_rounded), label: AppStrings.navNotices),
      const NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: AppStrings.navMap),
      const NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: AppStrings.navCalendar),
      const NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event_rounded), label: AppStrings.navEvents),
      if (isAdmin)
        const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: AppStrings.navAdmin),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: AppStrings.navProfile),
    ];

    // Índice válido
    final safeIndex = _index < screens.length ? _index : 0;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outline)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
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
