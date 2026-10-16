import 'package:flutter_test/flutter_test.dart';

import 'package:campusconnect/core/constants/app_strings.dart';

// NOTA: Un test de widgets completo (montar CampusConnectApp con
// WidgetTester.pumpWidget) requeriría simular Firebase, ya que
// Firebase.initializeApp() falla en el entorno de pruebas sin mocks
// (por ejemplo, con los paquetes firebase_auth_mocks / fake_cloud_firestore).
// Se deja este test mínimo como punto de partida del proyecto.
void main() {
  test('El nombre de la app está definido correctamente', () {
    expect(AppStrings.appName, 'CampusConnect');
  });

  test('El nombre de la universidad está definido correctamente', () {
    expect(AppStrings.universityName, 'Universidad Tecnológica del Valle del Mezquital');
  });
}
