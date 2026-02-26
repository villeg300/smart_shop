import 'dart:convert';
import '../models/category.dart';
import '../models/product.dart';
import '../models/variant.dart';
import 'api_client.dart';

class CatalogService {
  CatalogService(this._client);

  final ApiClient _client;

  /// Récupérer toutes les catégories
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _client.get('/api/shop/categories/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Erreur lors du chargement des catégories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement des catégories: $e');
    }
  }

  /// Récupérer les produits avec filtres optionnels
  Future<Map<String, dynamic>> fetchProducts({
    String? query,
    String? categorySlug,
    double? minPrice,
    double? maxPrice,
    String? attributes,
    String? ordering,
    int page = 1,
  }) async {
    try {
      // Construire les paramètres de requête
      final params = <String, String>{'page': page.toString()};

      if (query != null && query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }
      if (categorySlug != null &&
          categorySlug.isNotEmpty &&
          categorySlug != 'toutes') {
        params['category_slug'] = categorySlug;
      }
      if (minPrice != null) {
        params['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        params['max_price'] = maxPrice.toString();
      }
      if (attributes != null && attributes.isNotEmpty) {
        params['attributes'] = attributes;
      }
      if (ordering != null) {
        params['ordering'] = ordering;
      }

      // Construire l'URL avec les paramètres
      final uri = Uri.parse(
        '${_client.baseUrl}/api/shop/products/',
      ).replace(queryParameters: params);

      final response = await _client.get(
        uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final products = (data['results'] as List<dynamic>)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'products': products,
          'count': data['count'] as int,
          'next': data['next'] as String?,
          'previous': data['previous'] as String?,
        };
      } else {
        throw Exception(
          'Erreur lors du chargement des produits: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement des produits: $e');
    }
  }

  /// Récupérer un produit par son slug
  Future<Product> fetchProductBySlug(String slug) async {
    try {
      final response = await _client.get('/api/shop/products/$slug/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Produit non trouvé');
      } else {
        throw Exception(
          'Erreur lors du chargement du produit: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement du produit: $e');
    }
  }

  /// Récupérer les variantes avec filtres optionnels
  Future<Map<String, dynamic>> fetchVariants({
    String? categorySlug,
    String? productId,
    double? minPrice,
    double? maxPrice,
    String? attributes,
    bool? inStock,
    String? ordering,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': page.toString()};

      if (categorySlug != null &&
          categorySlug.isNotEmpty &&
          categorySlug != 'toutes') {
        params['category_slug'] = categorySlug;
      }
      if (productId != null) {
        params['product'] = productId;
      }
      if (minPrice != null) {
        params['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        params['max_price'] = maxPrice.toString();
      }
      if (attributes != null && attributes.isNotEmpty) {
        params['attributes'] = attributes;
      }
      if (inStock != null) {
        params['in_stock'] = inStock ? 'true' : 'false';
      }
      if (ordering != null) {
        params['ordering'] = ordering;
      }

      final uri = Uri.parse(
        '${_client.baseUrl}/api/shop/variants/',
      ).replace(queryParameters: params);

      final response = await _client.get(
        uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final variants = (data['results'] as List<dynamic>)
            .map((json) => Variant.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'variants': variants,
          'count': data['count'] as int,
          'next': data['next'] as String?,
          'previous': data['previous'] as String?,
        };
      } else {
        throw Exception(
          'Erreur lors du chargement des variantes: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement des variantes: $e');
    }
  }

  /// Récupérer une variante par son ID
  Future<Variant> fetchVariantById(String id) async {
    try {
      final response = await _client.get('/api/shop/variants/$id/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Variant.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Variante non trouvée');
      } else {
        throw Exception(
          'Erreur lors du chargement de la variante: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement de la variante: $e');
    }
  }

  /// Rechercher des produits/variantes
  Future<Map<String, dynamic>> searchProducts(
    String query, {
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'search': query, 'page': page.toString()};

      final uri = Uri.parse(
        '${_client.baseUrl}/api/shop/products/',
      ).replace(queryParameters: params);

      final response = await _client.get(
        uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final products = (data['results'] as List<dynamic>)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'products': products,
          'count': data['count'] as int,
          'next': data['next'] as String?,
          'previous': data['previous'] as String?,
        };
      } else {
        throw Exception('Erreur lors de la recherche: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de la recherche: $e');
    }
  }
}
