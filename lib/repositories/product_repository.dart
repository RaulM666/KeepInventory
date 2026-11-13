import 'dart:async';

import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/local_db_service.dart';
import '../utils/constants.dart';

class ProductsResult {
  final List<Product> items;
  final bool fromCache; // true = no hubo conexión, se muestran datos locales
  const ProductsResult(this.items, {required this.fromCache});
}

class ProductException implements Exception {
  final String message;
  ProductException(this.message);
  @override
  String toString() => message;
}

/// Repositorio de productos: coordina SQLite (local) y Firestore (remoto).
///
/// Estrategia "offline-first":
///  * Guardar: primero en SQLite (marcado como pendiente) y luego en Firestore.
///  * Leer: sube pendientes, descarga de Firestore y refresca SQLite.
///    Si no hay conexión, muestra lo que hay en SQLite.
class ProductRepository {
  ProductRepository(this._remote, [LocalDbService? local])
      : _local = local ?? LocalDbService.instance;

  final FirestoreService _remote;
  final LocalDbService _local;

  String newId() => _remote.newProductId();

  Future<List<Product>> localAll() => _local.getProducts();

  Future<ProductsResult> fetchAll() async {
    try {
      await _pushPending();
      final remote =
          await _remote.getProducts().timeout(AppConstants.remoteTimeout);
      await _local.replaceWithRemote(remote);
      return ProductsResult(await _local.getProducts(), fromCache: false);
    } catch (_) {
      return ProductsResult(await _local.getProducts(), fromCache: true);
    }
  }

  /// Crea o actualiza. Devuelve true si quedó sincronizado con Firestore.
  Future<bool> save(Product p) async {
    await _local.upsert(p, pending: true);
    try {
      await _remote.setProduct(p).timeout(AppConstants.remoteTimeout);
      await _local.markSynced(p.id);
      return true;
    } catch (_) {
      return false; // queda pendiente; se subirá en la próxima sincronización
    }
  }

  Future<void> delete(String id) async {
    try {
      await _remote.deleteProduct(id).timeout(AppConstants.remoteTimeout);
    } on TimeoutException {
      throw ProductException(
          'Sin conexión: no se pudo eliminar. Inténtalo con Internet.');
    } catch (_) {
      throw ProductException(
          'No se pudo eliminar el producto. Verifica tu conexión y tus permisos.');
    }
    await _local.delete(id);
  }

  Future<void> _pushPending() async {
    final pending = await _local.getPending();
    for (final p in pending) {
      await _remote.setProduct(p).timeout(AppConstants.remoteTimeout);
      await _local.markSynced(p.id);
    }
  }
}
