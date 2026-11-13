import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/product.dart';

/// Capa de acceso a la base de datos remota (Cloud Firestore).
/// Colecciones: `users` y `products`.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  // ---------- Usuarios ----------
  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.id, doc.data()!);
  }

  Future<void> setUser(AppUser user) =>
      _users.doc(user.uid).set(user.toJson());

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _users.doc(uid).update(data);

  Future<List<AppUser>> listUsers() async {
    final snap = await _users.get();
    final list = snap.docs.map((d) => AppUser.fromJson(d.id, d.data())).toList();
    list.sort((a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()));
    return list;
  }

  // ---------- Productos ----------
  String newProductId() => _products.doc().id;

  Future<List<Product>> getProducts() async {
    final snap = await _products.get();
    return snap.docs.map((d) => Product.fromJson(d.id, d.data())).toList();
  }

  Future<void> setProduct(Product p) => _products.doc(p.id).set(p.toJson());

  Future<void> deleteProduct(String id) => _products.doc(id).delete();
}
