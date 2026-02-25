import 'dart:convert';

import 'package:smart_shop/models/product.dart';

import 'api_client.dart';

class FavoriteService {
  FavoriteService(this._client);

  final ApiClient _client;

  Future<List<Product>> fetchFavorites() async {
    final response = await _client.get('/api/shop/favorites/');
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement des favoris: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => item as Map<String, dynamic>)
        .where((item) => item['product'] is Map<String, dynamic>)
        .map(
          (item) => Product.fromJson(item['product'] as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> addFavorite(String productId) async {
    final response = await _client.post('/api/shop/favorites/', {
      'product_id': productId,
    });

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }
  }

  Future<void> removeFavorite(String productId) async {
    final response = await _client.delete(
      '/api/shop/favorites/product/$productId/',
    );
    if (response.statusCode != 204) {
      throw Exception(_extractErrorMessage(response.body));
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      final detail = parsed['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
      return 'Erreur sur les favoris.';
    } catch (_) {
      return 'Erreur sur les favoris.';
    }
  }
}
