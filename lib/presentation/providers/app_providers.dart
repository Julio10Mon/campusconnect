import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/academic_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/user_management_remote_datasource.dart';
import '../../data/repositories/academic_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../domain/repositories/academic_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../../domain/usecases/get_events_usecase.dart';
import '../../domain/usecases/get_notices_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Firebase
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final academicRemoteDataSourceProvider = Provider<AcademicRemoteDataSource>((ref) {
  return AcademicRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

final userManagementRemoteDataSourceProvider = Provider<UserManagementRemoteDataSource>((ref) {
  return UserManagementRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

// Repositorios
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Escritura directa
final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepositoryImpl(ref.watch(academicRemoteDataSourceProvider));
});

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  return UserManagementRepositoryImpl(ref.watch(userManagementRemoteDataSourceProvider));
});

// Casos de uso
final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));

final getNoticesUseCaseProvider = Provider((ref) => GetNoticesUseCase(ref.watch(academicRepositoryProvider)));
final getEventsUseCaseProvider = Provider((ref) => GetEventsUseCase(ref.watch(academicRepositoryProvider)));
