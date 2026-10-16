import '../repositories/auth_repository.dart';

/// Caso de uso: logout
class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}
