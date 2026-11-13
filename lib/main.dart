import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/settings_controller.dart';
import 'firebase_options.dart';
import 'repositories/product_repository.dart';
import 'repositories/user_repository.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KeepInventoryApp());
}

class KeepInventoryApp extends StatelessWidget {
  const KeepInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyección de dependencias: servicios -> repositorios -> controladores.
    final firestore = FirestoreService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthController(AuthService(), UserRepository(firestore)),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductController(ProductRepository(firestore)),
        ),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          routes: AppRoutes.routes,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

/// Decide la pantalla inicial según el estado de la sesión.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isLoggedIn ? const HomeView() : const LoginView();
  }
}
