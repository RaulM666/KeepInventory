import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/ui.dart';

/// Pantalla de inicio: bienvenida, resumen del inventario y menú lateral.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().load();
    });
  }

  Future<void> _logout() async {
    final ok = await confirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Deseas cerrar tu sesión?',
      confirmText: 'Cerrar sesión',
    );
    if (!ok || !mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await context.read<AuthController>().logout();
  }

  void _go(String route) {
    Navigator.pop(context); // cierra el menú lateral
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    final products = context.watch<ProductController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primary),
                accountName: Text(user.username),
                accountEmail: Text(
                    '${user.email}  ·  ${AppRoles.label(user.role)}'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppTheme.accent,
                  child: Text(
                    user.username.isEmpty ? '?' : user.username[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 28, color: Colors.black),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Inicio'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Productos'),
                onTap: () => _go(AppRoutes.products),
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Agregar'),
                onTap: () => _go(AppRoutes.productForm),
              ),
              if (user.canUseCatalogApi)
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Catálogo API'),
                  onTap: () => _go(AppRoutes.catalog),
                ),
              if (user.canManageUsers)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Usuarios'),
                  onTap: () => _go(AppRoutes.users),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
                onTap: () => _go(AppRoutes.profile),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configuración'),
                onTap: () => _go(AppRoutes.settings),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.danger),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: products.load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Bienvenido a ${AppConstants.appName}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('${user.username} · ${AppRoles.label(user.role)}'),
            const SizedBox(height: 20),
            if (products.offline)
              const Card(
                color: Color(0xFFFFF3CD),
                child: ListTile(
                  leading: Icon(Icons.cloud_off, color: Colors.black87),
                  title: Text('Modo sin conexión',
                      style: TextStyle(color: Colors.black87)),
                  subtitle: Text('Mostrando datos guardados en el dispositivo.',
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2,
                    label: 'Productos',
                    value: '${products.total}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Stock bajo',
                    value: '${products.lowStockCount}',
                    color: products.lowStockCount > 0 ? AppTheme.danger : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.attach_money,
              label: 'Valor del inventario',
              value: money(products.inventoryValue),
            ),
            const SizedBox(height: 28),
            Align(
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.productForm),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo +'),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.products),
                icon: const Icon(Icons.list_alt),
                label: const Text('Ver todos los productos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color ?? AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color)),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
