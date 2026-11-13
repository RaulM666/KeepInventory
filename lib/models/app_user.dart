import '../utils/constants.dart';

/// Usuario de la aplicación con su rol y permisos.
class AppUser {
  final String uid;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == AppRoles.admin;

  // ---- Permisos por rol ----
  // Usuario: ver, crear y editar productos, gestionar su perfil.
  // Administrador: todo lo anterior + eliminar, gestionar usuarios y catálogo API.
  bool get canCreate => true;
  bool get canEdit => true;
  bool get canDelete => isAdmin;
  bool get canManageUsers => isAdmin;
  bool get canUseCatalogApi => isAdmin;

  AppUser copyWith({String? username, String? role}) => AppUser(
        uid: uid,
        username: username ?? this.username,
        email: email,
        role: role ?? this.role,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'role': role,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory AppUser.fromJson(String uid, Map<String, dynamic> j) => AppUser(
        uid: uid,
        username: (j['username'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        role: (j['role'] ?? AppRoles.user) as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (j['createdAt'] ?? 0) as int,
        ),
      );
}
