import 'package:flutter_test/flutter_test.dart';
import 'package:keep_inventory/models/app_user.dart';
import 'package:keep_inventory/models/product.dart';
import 'package:keep_inventory/utils/constants.dart';
import 'package:keep_inventory/utils/validators.dart';

void main() {
  group('Validators', () {
    test('correo válido e inválido', () {
      expect(Validators.email('alumno@correo.com'), isNull);
      expect(Validators.email('correo-malo'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('contraseña requiere 6 caracteres, letras y números', () {
      expect(Validators.password('abc123'), isNull);
      expect(Validators.password('abc'), isNotNull);
      expect(Validators.password('abcdef'), isNotNull);
    });

    test('precio y enteros', () {
      expect(Validators.price('199.50'), isNull);
      expect(Validators.price('-5'), isNotNull);
      expect(Validators.price('abc'), isNotNull);
      expect(Validators.integer('10'), isNull);
      expect(Validators.integer('1.5'), isNotNull);
    });
  });

  group('Modelos', () {
    test('Product: stock bajo y conversión JSON', () {
      final p = Product(
        id: 'a1',
        name: 'Pizza',
        description: 'Pizza de pepperoni al horno',
        category: 'Alimentos',
        price: 199,
        quantity: 3,
        minStock: 5,
        createdBy: 'u1',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      expect(p.lowStock, isTrue);
      final copy = Product.fromJson('a1', p.toJson());
      expect(copy.name, 'Pizza');
      expect(copy.price, 199);
    });

    test('AppUser: permisos por rol', () {
      AppUser build(String role) => AppUser(
          uid: 'u',
          username: 'x',
          email: 'x@x.com',
          role: role,
          createdAt: DateTime.now());
      expect(build(AppRoles.admin).canDelete, isTrue);
      expect(build(AppRoles.user).canDelete, isFalse);
      expect(build(AppRoles.user).canManageUsers, isFalse);
    });
  });
}
