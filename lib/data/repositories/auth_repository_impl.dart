import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Repositorio auth
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<bool> get authStateChanges =>
      _dataSource.authStateChanges.map((user) => user != null);

  @override
  bool get isLoggedIn => _dataSource.currentUser != null;

  @override
  Future<UserModel> login(String email, String password) =>
      _dataSource.login(email, password);

  @override
  Future<UserModel> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<UserModel> signInWithFacebook() => _dataSource.signInWithFacebook();

  @override
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  }) =>
      _dataSource.register(nombre: nombre, email: email, password: password);

  @override
  Future<void> sendPasswordReset(String email) =>
      _dataSource.sendPasswordReset(email);

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<UserModel> fetchCurrentProfile() => _dataSource.fetchCurrentProfile();

  @override
  Future<void> updateProfile(UserModel user) => _dataSource.updateProfile(user);
}
