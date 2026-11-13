import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

/// Controlador de autenticación y sesión (estado global con Provider).
class AuthController extends ChangeNotifier {
  AuthController(this._auth, this._users) {
    _sub = _auth.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _auth;
  final UserRepository _users;
  StreamSubscription<User?>? _sub;

  AppUser? user;
  bool initializing = true;
  bool busy = false;
  bool _registering = false;

  bool get isLoggedIn => user != null;

  Future<void> _onAuthChanged(User? fu) async {
    if (_registering) return; // el registro arma el perfil por su cuenta
    if (fu == null) {
      user = null;
    } else {
      try {
        user = await _users.getProfile(fu.uid) ??
            await _users.createProfile(
              uid: fu.uid,
              username: fu.displayName ?? (fu.email ?? 'usuario').split('@').first,
              email: fu.email ?? '',
            );
      } catch (_) {
        user = null;
      }
    }
    initializing = false;
    notifyListeners();
  }

  /// Devuelve null si todo salió bien o el mensaje de error.
  Future<String?> login(String email, String password) async {
    _setBusy(true);
    try {
      await _auth.signIn(email, password);
      return null;
    } catch (e) {
      return AuthService.friendlyError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    _registering = true;
    try {
      final fu = await _auth.register(email, password);
      await _auth.updateDisplayName(username.trim());
      user = await _users.createProfile(
        uid: fu.uid,
        username: username,
        email: email,
      );
      initializing = false;
      notifyListeners();
      return null;
    } catch (e) {
      return AuthService.friendlyError(e);
    } finally {
      _registering = false;
      _setBusy(false);
    }
  }

  Future<String?> recoverPassword(String email) async {
    _setBusy(true);
    try {
      await _auth.sendPasswordReset(email);
      return null;
    } catch (e) {
      return AuthService.friendlyError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<String?> updateUsername(String username) async {
    final u = user;
    if (u == null) return 'No hay sesión activa.';
    _setBusy(true);
    try {
      await _users.updateUsername(u.uid, username);
      await _auth.updateDisplayName(username.trim());
      user = u.copyWith(username: username.trim());
      notifyListeners();
      return null;
    } catch (_) {
      return 'No se pudo actualizar el perfil. Revisa tu conexión.';
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }

  void _setBusy(bool v) {
    busy = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
