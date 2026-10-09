import '../../data/models/user_model.dart';

/// Contrato auth
abstract class AuthRepository {
  Stream<bool> get authStateChanges;
  bool get isLoggedIn;

  Future<UserModel> login(String email, String password);

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithFacebook();

  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> logout();

  Future<UserModel> fetchCurrentProfile();

  Future<void> updateProfile(UserModel user);
}
