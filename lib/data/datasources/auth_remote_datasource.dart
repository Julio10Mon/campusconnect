import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Excepción auth
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Datasource auth
class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      return _fetchUserProfile(uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(nombre);

      final user = UserModel(
        uid: uid,
        nombre: nombre,
        correo: email.trim(),
        rol: UserRole.estudiante,
        creadoEn: DateTime.now(),
      );
      await _firestore.collection('usuarios').doc(uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  /// Login Google
  Future<UserModel> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    try {
      if (!googleSignIn.supportsAuthenticate()) {
        throw AuthException('Este dispositivo no admite inicio de sesión con Google.');
      }
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AuthException('No se pudo obtener el token de Google. Revisa la configuración del Web Client ID.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return _fetchUserProfile(userCredential.user!.uid);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Inicio de sesión con Google cancelado.');
      }
      throw AuthException('No se pudo iniciar sesión con Google (${e.code}).');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  /// Login Facebook
  Future<UserModel> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.cancelled) {
        throw AuthException('Inicio de sesión con Facebook cancelado.');
      }
      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw AuthException(result.message ?? 'No se pudo iniciar sesión con Facebook.');
      }
      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential = await _auth.signInWithCredential(credential);
      return _fetchUserProfile(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Cerrar sesión social
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignorar error
    }
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {
      // Ignorar error
    }
  }

  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    UserModel user;
    if (!doc.exists) {
      // Perfil mínimo
      user = UserModel(
        uid: uid,
        nombre: _auth.currentUser?.displayName ?? 'Usuario',
        correo: _auth.currentUser?.email ?? '',
      );
      await _firestore.collection('usuarios').doc(uid).set(user.toMap());
    } else {
      user = UserModel.fromMap(uid, doc.data()!);
    }

    if (!user.activo) {
      // Cuenta desactivada
      await _auth.signOut();
      throw AuthException('Tu cuenta fue desactivada. Contacta a un administrador de CampusConnect.');
    }

    return user;
  }

  Future<UserModel> fetchCurrentProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AuthException('No hay una sesión activa.');
    }
    return _fetchUserProfile(uid);
  }

  /// Actualizar perfil
  Future<void> updateProfile(UserModel user) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AuthException('No hay una sesión activa.');
    }
    await _firestore.collection('usuarios').doc(uid).update({
      'nombre': user.nombre,
      'carrera': user.carrera,
      'bio': user.bio,
      'fotoBase64': user.fotoBase64,
    });
    if (user.nombre != _auth.currentUser?.displayName) {
      await _auth.currentUser?.updateDisplayName(user.nombre);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión a Internet. Verifica tu red.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'No se pudo completar la operación (${e.code}).';
    }
  }
}
