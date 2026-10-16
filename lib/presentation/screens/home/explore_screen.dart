import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/screen_header.dart';
import 'calendar_screen.dart';
import 'map_screen.dart';

/// Sección "Explorar": consulta del calendario de eventos y del mapa de
/// ubicaciones (ambos de solo lectura para los usuarios).
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
          title: const ScreenHeaderTitle(title: AppStrings.navExplore),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.orange,
            tabs: [
              Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Calendario de eventos'),
              Tab(icon: Icon(Icons.map_outlined), text: 'Mapa de ubicaciones'),
            ],
          ),
        ),
        body: const TabBarView(children: [CalendarScreen(), MapScreen()]),
      ),
    );
  }
}
