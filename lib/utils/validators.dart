/// Validaciones reutilizables para formularios (devuelven null si es válido).
class Validators {
  static String? required(String? v, [String field = 'Este campo']) {
    if (v == null || v.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? username(String? v) {
    final r = required(v, 'El nombre de usuario');
    if (r != null) return r;
    if (v!.trim().length < 3) return 'Mínimo 3 caracteres';
    if (v.trim().length > 30) return 'Máximo 30 caracteres';
    return null;
  }

  static String? email(String? v) {
    final r = required(v, 'El correo');
    if (r != null) return r;
    final ok = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$').hasMatch(v!.trim());
    return ok ? null : 'Escribe un correo válido';
  }

  static String? password(String? v) {
    final r = required(v, 'La contraseña');
    if (r != null) return r;
    if (v!.length < 6) return 'Mínimo 6 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Debe incluir letras y números';
    }
    return null;
  }

  static String? price(String? v) {
    final r = required(v, 'El precio');
    if (r != null) return r;
    final n = double.tryParse(v!.trim().replaceAll(',', '.'));
    if (n == null) return 'Escribe un número válido';
    if (n < 0) return 'El precio no puede ser negativo';
    return null;
  }

  static String? integer(String? v, {String field = 'El valor', int min = 0}) {
    final r = required(v, field);
    if (r != null) return r;
    final n = int.tryParse(v!.trim());
    if (n == null) return 'Escribe un número entero';
    if (n < min) return '$field debe ser mayor o igual a $min';
    return null;
  }

  static String? productName(String? v) {
    final r = required(v, 'El nombre del producto');
    if (r != null) return r;
    if (v!.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }
}
