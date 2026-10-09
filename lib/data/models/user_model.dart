import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles
enum UserRole { estudiante, admin }

UserRole roleFromString(String? value) {
  switch (value) {
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.estudiante;
  }
}

String roleToString(UserRole role) => role.name;

/// Modelo usuario
class UserModel {
  final String uid;
  final String nombre;
  final String correo;
  final UserRole rol;
  final String? carrera;
  final String? bio;
  final String? fotoBase64;
  final bool activo;
  final DateTime? creadoEn;

  const UserModel({
    required this.uid,
    required this.nombre,
    required this.correo,
    this.rol = UserRole.estudiante,
    this.carrera,
    this.bio,
    this.fotoBase64,
    this.activo = true,
    this.creadoEn,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      nombre: map['nombre'] as String? ?? '',
      correo: map['correo'] as String? ?? '',
      rol: roleFromString(map['rol'] as String?),
      carrera: map['carrera'] as String?,
      bio: map['bio'] as String?,
      fotoBase64: map['fotoBase64'] as String?,
      activo: map['activo'] as bool? ?? true,
      creadoEn: (map['creadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'correo': correo,
      'rol': roleToString(rol),
      'carrera': carrera,
      'bio': bio,
      'fotoBase64': fotoBase64,
      'activo': activo,
      'creadoEn': creadoEn != null ? Timestamp.fromDate(creadoEn!) : FieldValue.serverTimestamp(),
    };
  }

  /// copyWith
  UserModel copyWith({String? nombre, String? carrera, String? bio, String? fotoBase64}) {
    return UserModel(
      uid: uid,
      nombre: nombre ?? this.nombre,
      correo: correo,
      rol: rol,
      carrera: carrera ?? this.carrera,
      bio: bio ?? this.bio,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      activo: activo,
      creadoEn: creadoEn,
    );
  }
}
