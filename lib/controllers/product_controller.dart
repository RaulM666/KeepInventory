import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Controlador del inventario: estado de la lista y operaciones CRUD.
class ProductController extends ChangeNotifier {
  ProductController(this._repo);
  final ProductRepository _repo;

  List<Product> _all = [];
  bool loading = false;
  bool offline = false;
  String _query = '';

  List<Product> get all => _all;

  List<Product> get filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  int get total => _all.length;
  int get lowStockCount => _all.where((p) => p.lowStock).length;
  double get inventoryValue => _all.fold(0.0, (s, p) => s + p.totalValue);

  String newId() => _repo.newId();

  void setQuery(String q) {
    _query = q.trim();
    notifyListeners();
  }

  /// READ: carga desde Firestore (o SQLite si no hay conexión).
  Future<void> load() async {
    loading = true;
    notifyListeners();
    final result = await _repo.fetchAll();
    _all = result.items;
    offline = result.fromCache;
    loading = false;
    notifyListeners();
  }

  /// CREATE / UPDATE. Devuelve el mensaje que se mostrará al usuario.
  Future<String> save(Product p) async {
    final synced = await _repo.save(p);
    _all = await _repo.localAll();
    offline = !synced;
    notifyListeners();
    return synced
        ? 'Producto guardado correctamente.'
        : 'Guardado en el dispositivo. Se sincronizará cuando haya conexión.';
  }

  /// DELETE: solo el Administrador. Lanza [ProductException] si falla.
  Future<void> remove(Product p, AppUser actor) async {
    if (!actor.canDelete) {
      throw ProductException('Tu rol no tiene permiso para eliminar productos.');
    }
    await _repo.delete(p.id);
    _all = _all.where((x) => x.id != p.id).toList();
    notifyListeners();
  }
}
