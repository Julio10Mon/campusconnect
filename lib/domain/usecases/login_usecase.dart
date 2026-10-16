import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: login
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<UserModel> call(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Correo y contraseña son obligatorios.');
    }
    return _repository.login(email, password);
  }
}
