import 'package:campusconnect/presentation/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stagger limita el retraso a 8 elementos', () {
    expect(Motion.stagger(0), Duration.zero);
    expect(Motion.stagger(3), const Duration(milliseconds: 165));
    expect(Motion.stagger(50), Motion.stagger(8));
  });

  testWidgets('CountUp muestra el valor final al terminar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CountUp(value: 7)));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('FadeSlideIn termina visible', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FadeSlideIn(child: Text('hola'))));
    await tester.pumpAndSettle();
    expect(find.text('hola'), findsOneWidget);
  });
}
