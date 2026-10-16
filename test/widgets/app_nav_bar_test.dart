import 'package:campusconnect/presentation/widgets/app_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const items = [
    AppNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Inicio'),
    AppNavItem(icon: Icons.event_outlined, selectedIcon: Icons.event_rounded, label: 'Eventos'),
  ];

  testWidgets('AppNavBar avisa la pestaña tocada', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: AppNavBar(
              selectedIndex: selected,
              onSelected: (i) => setState(() => selected = i),
              items: items,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Inicio'), findsOneWidget);
    await tester.tap(find.text('Eventos'));
    await tester.pumpAndSettle();
    expect(selected, 1);
  });
}
