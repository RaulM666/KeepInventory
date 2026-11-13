import '../models/app_user.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

/// Repositorio de usuarios: oculta a los controladores de dónde se guardan.
class UserRepository {
  UserRepository(this._remote);
  final FirestoreService _remote;

  Future<AppUser?> getProfile(String uid) => _remote.getUser(uid);

  Future<AppUser> createProfile({
    required String uid,
    required String username,
    required String email,
  }) async {
    final isSeedAdmin =
        email.trim().toLowerCase() == AppConstants.seedAdminEmail;
    final user = AppUser(
      uid: uid,
      username: username.trim(),
      email: email.trim(),
      role: isSeedAdmin ? AppRoles.admin : AppRoles.user,
      createdAt: DateTime.now(),
    );
    await _remote.setUser(user);
    return user;
  }

  Future<void> updateUsername(String uid, String username) =>
      _remote.updateUser(uid, {'username': username.trim()});

  Future<void> setRole(String uid, String role) =>
      _remote.updateUser(uid, {'role': role});

  Future<List<AppUser>> listUsers() => _remote.listUsers();
}
