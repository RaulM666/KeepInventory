/// Producto del inventario.
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int quantity;
  final int minStock;

  /// Foto tomada de la galería (solo existe en el dispositivo).
  final String? imagePath;

  /// Foto remota (por ejemplo, al importar desde el catálogo API).
  final String? imageUrl;
  final String createdBy;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.minStock,
    required this.createdBy,
    required this.updatedAt,
    this.imagePath,
    this.imageUrl,
  });

  bool get lowStock => quantity <= minStock;
  double get totalValue => price * quantity;

  Product copyWith({
    String? name,
    String? description,
    String? category,
    double? price,
    int? quantity,
    int? minStock,
    String? imagePath,
    String? imageUrl,
    DateTime? updatedAt,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        minStock: minStock ?? this.minStock,
        imagePath: imagePath ?? this.imagePath,
        imageUrl: imageUrl ?? this.imageUrl,
        createdBy: createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  // ---------- Remoto (Firestore) ----------
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'quantity': quantity,
        'minStock': minStock,
        'imageUrl': imageUrl,
        'createdBy': createdBy,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory Product.fromJson(String id, Map<String, dynamic> j) => Product(
        id: id,
        name: (j['name'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        category: (j['category'] ?? 'General') as String,
        price: ((j['price'] ?? 0) as num).toDouble(),
        quantity: ((j['quantity'] ?? 0) as num).toInt(),
        minStock: ((j['minStock'] ?? 0) as num).toInt(),
        imageUrl: j['imageUrl'] as String?,
        createdBy: (j['createdBy'] ?? '') as String,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          ((j['updatedAt'] ?? 0) as num).toInt(),
        ),
      );

  // ---------- Local (SQLite) ----------
  Map<String, Object?> toDb({bool pending = false}) => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'quantity': quantity,
        'min_stock': minStock,
        'image_path': imagePath,
        'image_url': imageUrl,
        'created_by': createdBy,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'pending_sync': pending ? 1 : 0,
      };

  factory Product.fromDb(Map<String, Object?> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        description: (m['description'] ?? '') as String,
        category: (m['category'] ?? 'General') as String,
        price: (m['price'] as num).toDouble(),
        quantity: (m['quantity'] as num).toInt(),
        minStock: (m['min_stock'] as num).toInt(),
        imagePath: m['image_path'] as String?,
        imageUrl: m['image_url'] as String?,
        createdBy: (m['created_by'] ?? '') as String,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (m['updated_at'] as num).toInt(),
        ),
      );
}
