import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Datasource admin usuarios
class UserManagementRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserManagementRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<UserModel>> watchAllUsers() {
    return _firestore.collection('usuarios').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<void> updateRole(String uid, UserRole rol) {
    return _firestore.collection('usuarios').doc(uid).update({'rol': roleToString(rol)});
  }

  Future<void> setActive(String uid, bool activo) {
    return _firestore.collection('usuarios').doc(uid).update({'activo': activo});
  }

  /// Editar usuario
  Future<void> updateUserInfo(String uid, {required String nombre, String? carrera}) {
    return _firestore.collection('usuarios').doc(uid).update({
      'nombre': nombre,
      'carrera': carrera,
    });
  }
}
