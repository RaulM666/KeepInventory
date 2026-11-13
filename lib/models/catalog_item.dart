/// Producto del catálogo externo (API REST pública DummyJSON).
class CatalogItem {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final int stock;
  final String? thumbnail;

  const CatalogItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    this.thumbnail,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> j) => CatalogItem(
        id: (j['id'] as num).toInt(),
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        category: (j['category'] ?? 'General') as String,
        price: ((j['price'] ?? 0) as num).toDouble(),
        stock: ((j['stock'] ?? 0) as num).toInt(),
        thumbnail: j['thumbnail'] as String?,
      );
}

/// Resultado crudo de una llamada a la API (para mostrar método, URL y respuesta).
class ApiResult {
  final String method;
  final String url;
  final int statusCode;
  final String body;

  const ApiResult({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.body,
  });

  bool get ok => statusCode >= 200 && statusCode < 300;
}
