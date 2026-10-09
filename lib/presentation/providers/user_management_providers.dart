import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import 'app_providers.dart';

/// Usuarios (admin)
final allUsersStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return ref.watch(userManagementRepositoryProvider).watchAllUsers();
});

/// Estado acción admin
sealed class AdminActionState {
  const AdminActionState();
}

class AdminActionIdle extends AdminActionState {
  const AdminActionIdle();
}

class AdminActionLoading extends AdminActionState {
  const AdminActionLoading();
}

class AdminActionError extends AdminActionState {
  final String message;
  const AdminActionError(this.message);
}

class AdminActionSuccess extends AdminActionState {
  const AdminActionSuccess();
}

class UserAdminController extends StateNotifier<AdminActionState> {
  final Ref _ref;
  UserAdminController(this._ref) : super(const AdminActionIdle());

  Future<void> changeRole(String uid, UserRole rol) => _run(
        () => _ref.read(userManagementRepositoryProvider).updateRole(uid, rol),
      );

  Future<void> setActive(String uid, bool activo) => _run(
        () => _ref.read(userManagementRepositoryProvider).setActive(uid, activo),
      );

  Future<void> updateInfo(String uid, {required String nombre, String? carrera}) => _run(
        () => _ref.read(userManagementRepositoryProvider).updateUserInfo(uid, nombre: nombre, carrera: carrera),
      );

  Future<void> _run(Future<void> Function() action) async {
    state = const AdminActionLoading();
    try {
      await action();
      state = const AdminActionSuccess();
    } catch (e) {
      state = AdminActionError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const AdminActionIdle();
}

final userAdminControllerProvider =
    StateNotifierProvider.autoDispose<UserAdminController, AdminActionState>(
  (ref) => UserAdminController(ref),
);
