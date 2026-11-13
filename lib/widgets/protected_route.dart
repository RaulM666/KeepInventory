import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

/// Protección de rutas: exige sesión iniciada y, opcionalmente, rol Administrador.
class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({super.key, required this.child, this.adminOnly = false});

  final Widget child;
  final bool adminOnly;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) {
      return const _Denied(
        icon: Icons.lock_outline,
        message: 'Debes iniciar sesión para ver esta pantalla.',
      );
    }
    if (adminOnly && !user.isAdmin) {
      return const _Denied(
        icon: Icons.block,
        message: 'Acceso denegado: esta sección es solo para Administradores.',
      );
    }
    return child;
  }
}

class _Denied extends StatelessWidget {
  const _Denied({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso restringido')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
