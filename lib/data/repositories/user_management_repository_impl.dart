import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_remote_datasource.dart';
import '../models/user_model.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource _dataSource;

  UserManagementRepositoryImpl(this._dataSource);

  @override
  Stream<List<UserModel>> watchAllUsers() => _dataSource.watchAllUsers();

  @override
  Future<void> updateRole(String uid, UserRole rol) => _dataSource.updateRole(uid, rol);

  @override
  Future<void> setActive(String uid, bool activo) => _dataSource.setActive(uid, activo);

  @override
  Future<void> updateUserInfo(String uid, {required String nombre, String? carrera}) =>
      _dataSource.updateUserInfo(uid, nombre: nombre, carrera: carrera);
}
