import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/product_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/constants.dart';
import '../utils/ui.dart';

/// Pantalla "Configuración": modo oscuro (guardado local) y sincronización manual.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo oscuro'),
            subtitle: const Text('Se guarda en este dispositivo'),
            value: settings.darkMode,
            onChanged: settings.setDarkMode,
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sincronizar ahora'),
            subtitle: const Text('Sube cambios pendientes y descarga el inventario'),
            onTap: () async {
              final ctrl = context.read<ProductController>();
              await ctrl.load();
              if (!context.mounted) return;
              showMessage(
                context,
                ctrl.offline
                    ? 'Sin conexión: se mantienen los datos locales.'
                    : 'Inventario sincronizado.',
                error: ctrl.offline,
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppConstants.appName),
            subtitle: Text('Versión 1.0.0 · Control de inventario móvil'),
          ),
        ],
      ),
    );
  }
}
