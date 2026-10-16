import '../../data/models/user_model.dart';

/// Contrato admin usuarios
abstract class UserManagementRepository {
  Stream<List<UserModel>> watchAllUsers();

  Future<void> updateRole(String uid, UserRole rol);

  Future<void> setActive(String uid, bool activo);

  Future<void> updateUserInfo(String uid, {required String nombre, String? carrera});
}
