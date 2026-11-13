import 'package:flutter/material.dart';

import '../models/product.dart';
import '../views/catalog_api_view.dart';
import '../views/forgot_password_view.dart';
import '../views/product_form_view.dart';
import '../views/products_view.dart';
import '../views/profile_view.dart';
import '../views/register_view.dart';
import '../views/settings_view.dart';
import '../views/users_admin_view.dart';
import '../widgets/protected_route.dart';

/// Mapa de navegación de la aplicación.
/// La ruta "/" (inicio) la resuelve AuthGate en main.dart:
///   sin sesión -> LoginView, con sesión -> HomeView.
class AppRoutes {
  static const register = '/register';
  static const forgot = '/forgot';
  static const products = '/products';
  static const productForm = '/products/form';
  static const catalog = '/catalog';
  static const users = '/users';
  static const profile = '/profile';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        register: (_) => const RegisterView(),
        forgot: (_) => const ForgotPasswordView(),
        products: (_) => const ProtectedRoute(child: ProductsView()),
        productForm: (ctx) => ProtectedRoute(
              child: ProductFormView(
                product: ModalRoute.of(ctx)?.settings.arguments as Product?,
              ),
            ),
        catalog: (_) =>
            const ProtectedRoute(adminOnly: true, child: CatalogApiView()),
        users: (_) =>
            const ProtectedRoute(adminOnly: true, child: UsersAdminView()),
        profile: (_) => const ProtectedRoute(child: ProfileView()),
        settings: (_) => const ProtectedRoute(child: SettingsView()),
      };
}
