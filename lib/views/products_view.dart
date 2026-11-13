import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../routes/app_routes.dart';
import '../utils/ui.dart';
import '../widgets/product_card.dart';

/// Pantalla "Productos": lista, búsqueda, edición y eliminación (solo Admin).
class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().load();
    });
  }

  Future<void> _delete(Product p) async {
    final user = context.read<AuthController>().user!;
    final ok = await confirmDialog(
      context,
      title: 'Eliminar producto',
      message: '¿Seguro que deseas eliminar "${p.name}"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await context.read<ProductController>().remove(p, user);
      if (mounted) showMessage(context, 'Producto eliminado.');
    } on ProductException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    final ctrl = context.watch<ProductController>();
    final items = ctrl.filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.productForm),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: Column(
        children: [
          if (ctrl.offline)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF3CD),
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Sin conexión: mostrando datos del dispositivo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: ctrl.setQuery,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o categoría',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ctrl.loading && ctrl.all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: ctrl.load,
                    child: items.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('No hay productos para mostrar.')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final p = items[i];
                              return ProductCard(
                                product: p,
                                onEdit: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.productForm,
                                  arguments: p,
                                ),
                                onDelete:
                                    user.canDelete ? () => _delete(p) : null,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
