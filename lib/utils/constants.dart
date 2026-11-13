/// Constantes globales de KeepInventory.
class AppConstants {
  static const String appName = 'KeepInventory';

  /// Correo "semilla": la cuenta que se registre con este correo nace como
  /// Administrador. Todas las demás nacen como Usuario y el administrador
  /// puede promoverlas desde el módulo "Usuarios".
  static const String seedAdminEmail = 'admin@keepinventory.com';

  /// Base de la API REST pública usada en el módulo "Catálogo API".
  static const String apiBaseUrl = 'https://dummyjson.com';

  /// Tiempo máximo de espera para operaciones remotas.
  static const Duration remoteTimeout = Duration(seconds: 8);

  static const List<String> categories = [
    'General',
    'Alimentos',
    'Bebidas',
    'Limpieza',
    'Electrónica',
    'Papelería',
    'Ropa',
    'Otros',
  ];
}

class AppRoles {
  static const String admin = 'admin';
  static const String user = 'usuario';

  static String label(String role) =>
      role == admin ? 'Administrador' : 'Usuario';
}
