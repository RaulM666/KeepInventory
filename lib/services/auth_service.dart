import 'package:firebase_auth/firebase_auth.dart';

/// Capa de acceso a Firebase Authentication.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<User> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  /// Traduce errores de Firebase a mensajes claros en español.
  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'El correo no tiene un formato válido.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo.';
        case 'weak-password':
          return 'La contraseña es muy débil.';
        case 'user-disabled':
          return 'Esta cuenta fue deshabilitada.';
        case 'too-many-requests':
          return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
        case 'network-request-failed':
          return 'Sin conexión a Internet. Revisa tu red.';
        default:
          return 'Error de autenticación (${e.code}).';
      }
    }
    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
  }
}
