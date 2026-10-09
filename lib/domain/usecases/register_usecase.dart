import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: registro
class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<UserModel> call({
    required String nombre,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (nombre.trim().length < 3) {
      throw ArgumentError('Ingresa tu nombre completo.');
    }
    if (password.length < 6) {
      throw ArgumentError('La contraseña debe tener al menos 6 caracteres.');
    }
    if (password != confirmPassword) {
      throw ArgumentError('Las contraseñas no coinciden.');
    }
    return _repository.register(nombre: nombre, email: email, password: password);
  }
}
