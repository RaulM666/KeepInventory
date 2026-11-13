import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

/// Persistencia LOCAL con SQLite (funciona sin conexión).
/// Guarda una copia de los productos y marca los cambios pendientes de subir.
class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'keepinventory.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT,
            price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            min_stock INTEGER NOT NULL,
            image_path TEXT,
            image_url TEXT,
            created_by TEXT,
            updated_at INTEGER NOT NULL,
            pending_sync INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await _database;
    final rows = await db.query('products', orderBy: 'name COLLATE NOCASE');
    return rows.map(Product.fromDb).toList();
  }

  Future<List<Product>> getPending() async {
    final db = await _database;
    final rows = await db.query('products', where: 'pending_sync = 1');
    return rows.map(Product.fromDb).toList();
  }

  Future<void> upsert(Product p, {bool pending = false}) async {
    final db = await _database;
    await db.insert('products', p.toDb(pending: pending),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markSynced(String id) async {
    final db = await _database;
    await db.update('products', {'pending_sync': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Reemplaza la copia local con los datos remotos, respetando los cambios
  /// pendientes de sincronizar y la foto local de cada producto.
  Future<void> replaceWithRemote(List<Product> remote) async {
    final db = await _database;
    final existing = await db.query('products');
    final byId = {for (final r in existing) r['id'] as String: r};

    await db.transaction((txn) async {
      final remoteIds = <String>{};
      for (final p in remote) {
        remoteIds.add(p.id);
        final old = byId[p.id];
        if (old != null && old['pending_sync'] == 1) continue; // local más nuevo
        final merged = p.copyWith(imagePath: old?['image_path'] as String?);
        await txn.insert('products', merged.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final r in existing) {
        final id = r['id'] as String;
        if (!remoteIds.contains(id) && r['pending_sync'] != 1) {
          await txn.delete('products', where: 'id = ?', whereArgs: [id]);
        }
      }
    });
  }
}
