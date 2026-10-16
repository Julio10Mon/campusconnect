import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import 'app_providers.dart';

/// Sesión activa
final authStateProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Perfil actual
final currentUserProvider = FutureProvider.autoDispose<UserModel>((ref) {
  return ref.watch(authRepositoryProvider).fetchCurrentProfile();
});

/// Estado auth
sealed class AuthFormState {
  const AuthFormState();
}

class AuthFormIdle extends AuthFormState {
  const AuthFormIdle();
}

class AuthFormLoading extends AuthFormState {
  const AuthFormLoading();
}

class AuthFormError extends AuthFormState {
  final String message;
  const AuthFormError(this.message);
}

class AuthFormSuccess extends AuthFormState {
  const AuthFormSuccess();
}

/// Controlador auth
class AuthController extends StateNotifier<AuthFormState> {
  final Ref _ref;
  AuthController(this._ref) : super(const AuthFormIdle());

  Future<void> login(String email, String password) async {
    state = const AuthFormLoading();
    try {
      await _ref.read(loginUseCaseProvider).call(email, password);
      state = const AuthFormSuccess();
    } catch (e) {
      state = AuthFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthFormLoading();
    try {
      await _ref.read(registerUseCaseProvider).call(
            nombre: nombre,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
          );
      state = const AuthFormSuccess();
    } catch (e) {
      state = AuthFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AuthFormLoading();
    try {
      await _ref.read(authRepositoryProvider).sendPasswordReset(email);
      state = const AuthFormSuccess();
    } catch (e) {
      state = AuthFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthFormLoading();
    try {
      await _ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AuthFormSuccess();
    } catch (e) {
      state = AuthFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> loginWithFacebook() async {
    state = const AuthFormLoading();
    try {
      await _ref.read(authRepositoryProvider).signInWithFacebook();
      state = const AuthFormSuccess();
    } catch (e) {
      state = AuthFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() => _ref.read(logoutUseCaseProvider).call();

  void reset() => state = const AuthFormIdle();
}

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AuthFormState>(
  (ref) => AuthController(ref),
);
