import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../models/catalog_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/ui.dart';

/// Módulo "Catálogo API" (solo Administrador).
///  GET    -> lista el catálogo externo.
///  Importar -> guarda el producto en el inventario (Firestore + SQLite).
///  POST / PUT / PATCH / DELETE -> pruebas contra la API, mostrando la respuesta.
class CatalogApiView extends StatefulWidget {
  const CatalogApiView({super.key});

  @override
  State<CatalogApiView> createState() => _CatalogApiViewState();
}

class _CatalogApiViewState extends State<CatalogApiView> {
  final _api = ApiService();
  List<CatalogItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.getProducts(limit: 20);
      if (mounted) setState(() => _items = list);
    } on TimeoutException {
      if (mounted) setState(() => _error = 'Tiempo de espera agotado. Revisa tu conexión.');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo conectar con la API (¿sin Internet?).');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _import(CatalogItem item) async {
    final ctrl = context.read<ProductController>();
    final user = context.read<AuthController>().user!;
    final category = AppConstants.categories.contains(item.category)
        ? item.category
        : 'General';
    final product = Product(
      id: ctrl.newId(),
      name: item.title,
      description: item.description,
      category: category,
      price: item.price,
      quantity: item.stock,
      minStock: 5,
      imageUrl: item.thumbnail,
      createdBy: user.uid,
      updatedAt: DateTime.now(),
    );
    final msg = await ctrl.save(product);
    if (mounted) showMessage(context, 'Importado: ${item.title}. $msg');
  }

  Future<void> _call(String method, CatalogItem item) async {
    try {
      late ApiResult r;
      switch (method) {
        case 'POST':
          r = await _api.createProduct({'title': item.title, 'price': item.price});
          break;
        case 'PUT':
          r = await _api.updateProduct(
              item.id, {'title': item.title, 'price': item.price});
          break;
        case 'PATCH':
          r = await _api.patchProduct(item.id, {'price': item.price + 1});
          break;
        default:
          r = await _api.deleteProduct(item.id);
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${r.method}  ·  ${r.statusCode}'),
          content: SingleChildScrollView(
            child: SelectableText('${r.url}\n\n${r.body}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Falló la llamada $method. Revisa tu conexión.',
            error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo API')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final it = _items[i];
                      return Card(
                        child: ListTile(
                          leading: it.thumbnail == null
                              ? const Icon(Icons.inventory_2_outlined)
                              : Image.network(it.thumbnail!,
                                  width: 48,
                                  height: 48,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.inventory_2_outlined)),
                          title: Text(it.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${money(it.price)} · ${it.category} · stock ${it.stock}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) =>
                                v == 'IMPORT' ? _import(it) : _call(v, it),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'IMPORT', child: Text('Importar al inventario')),
                              PopupMenuItem(value: 'POST', child: Text('Probar POST')),
                              PopupMenuItem(value: 'PUT', child: Text('Probar PUT')),
                              PopupMenuItem(value: 'PATCH', child: Text('Probar PATCH')),
                              PopupMenuItem(value: 'DELETE', child: Text('Probar DELETE')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
