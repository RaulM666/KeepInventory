import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/catalog_item.dart';
import '../utils/constants.dart';

/// Consumo de la API REST pública DummyJSON (https://dummyjson.com).
/// Es una API de pruebas: acepta POST/PUT/PATCH/DELETE pero SIMULA los cambios
/// (responde correctamente sin guardar nada de forma permanente).
///
/// Autenticación: la API no requiere token; el acceso al módulo está protegido
/// por Firebase Authentication y por el rol Administrador dentro de la app.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${AppConstants.apiBaseUrl}$path').replace(queryParameters: query);

  ApiResult _result(String method, http.Response r) => ApiResult(
        method: method,
        url: r.request?.url.toString() ?? '',
        statusCode: r.statusCode,
        body: const JsonEncoder.withIndent('  ').convert(_safeJson(r.body)),
      );

  dynamic _safeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'raw': body};
    }
  }

  /// GET /products?limit=n  -> lista de productos del catálogo.
  Future<List<CatalogItem>> getProducts({int limit = 20}) async {
    final r = await _client
        .get(_uri('/products', {'limit': '$limit'}), headers: _headers)
        .timeout(AppConstants.remoteTimeout);
    if (r.statusCode != 200) {
      throw ApiException('El servidor respondió ${r.statusCode}.');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (data['products'] as List)
        .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /products/add -> crea un producto (simulado).
  Future<ApiResult> createProduct(Map<String, dynamic> body) async {
    final r = await _client
        .post(_uri('/products/add'), headers: _headers, body: jsonEncode(body))
        .timeout(AppConstants.remoteTimeout);
    return _result('POST', r);
  }

  /// PUT /products/{id} -> reemplaza datos de un producto (simulado).
  Future<ApiResult> updateProduct(int id, Map<String, dynamic> body) async {
    final r = await _client
        .put(_uri('/products/$id'), headers: _headers, body: jsonEncode(body))
        .timeout(AppConstants.remoteTimeout);
    return _result('PUT', r);
  }

  /// PATCH /products/{id} -> actualiza parcialmente (simulado).
  Future<ApiResult> patchProduct(int id, Map<String, dynamic> body) async {
    final r = await _client
        .patch(_uri('/products/$id'), headers: _headers, body: jsonEncode(body))
        .timeout(AppConstants.remoteTimeout);
    return _result('PATCH', r);
  }

  /// DELETE /products/{id} -> elimina un producto (simulado).
  Future<ApiResult> deleteProduct(int id) async {
    final r = await _client
        .delete(_uri('/products/$id'), headers: _headers)
        .timeout(AppConstants.remoteTimeout);
    return _result('DELETE', r);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
