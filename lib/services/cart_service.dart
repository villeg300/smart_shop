import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../models/cart.dart';
import 'api_client.dart';

class CartService {
  CartService(this._client);

  final ApiClient _client;

  /// Récupère le panier de l'utilisateur courant.
  Future<Cart?> fetchCart() async {
    try {
      final response = await _client.get('/api/shop/carts/');

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('fetchCart error ${response.statusCode}: ${response.body}');
        throw Exception(
          'Erreur lors du chargement du panier: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      // DRF peut répondre avec liste, pagination ou objet direct.
      if (decoded is List) {
        if (decoded.isEmpty) return null;
        return Cart.fromJson(decoded.first as Map<String, dynamic>);
      }

      if (decoded is Map<String, dynamic>) {
        if (decoded['results'] is List) {
          final results = decoded['results'] as List<dynamic>;
          if (results.isEmpty) return null;
          return Cart.fromJson(results.first as Map<String, dynamic>);
        }

        if (decoded.containsKey('id')) {
          return Cart.fromJson(decoded);
        }

        return null;
      }

      throw Exception('Réponse panier inattendue: ${decoded.runtimeType}');
    } catch (e) {
      debugPrint('fetchCart exception: $e');
      throw Exception('Erreur réseau lors du chargement du panier: $e');
    }
  }

  /// Crée (ou retourne) le panier courant. Backend idempotent (200/201).
  Future<Cart> createCart() async {
    try {
      final response = await _client.post('/api/shop/carts/', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cart.fromJson(data);
      }

      debugPrint('createCart error ${response.statusCode}: ${response.body}');
      throw Exception(
        'Erreur lors de la création du panier: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('createCart exception: $e');
      throw Exception('Erreur réseau lors de la création du panier: $e');
    }
  }

  Future<CartItem> addToCart({
    required String cartId,
    required String variantId,
    int quantity = 1,
    double? unitPrice,
  }) async {
    try {
      final body = <String, dynamic>{
        'cart': cartId,
        'variant_id': variantId,
        'quantity': quantity,
      };

      if (unitPrice != null) {
        body['unit_price'] = unitPrice;
      }

      final response = await _client.post('/api/shop/cart-items/', body);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CartItem.fromJson(data);
      }

      if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Erreur lors de l\'ajout au panier');
      }

      debugPrint('addToCart error ${response.statusCode}: ${response.body}');
      throw Exception(
        'Erreur lors de l\'ajout au panier: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('addToCart exception: $e');
      throw Exception('Erreur réseau lors de l\'ajout au panier: $e');
    }
  }

  /// Mise à jour partielle d'un item panier (PATCH).
  Future<CartItem> updateCartItem({
    required String itemId,
    required int quantity,
    double? unitPrice,
  }) async {
    try {
      final body = <String, dynamic>{'quantity': quantity};

      if (unitPrice != null) {
        body['unit_price'] = unitPrice;
      }

      final response = await _client.patch(
        '/api/shop/cart-items/$itemId/',
        body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CartItem.fromJson(data);
      }

      debugPrint(
        'updateCartItem error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    } catch (e) {
      debugPrint('updateCartItem exception: $e');
      throw Exception('Erreur réseau lors de la mise à jour: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final response = await _client.delete('/api/shop/cart-items/$itemId/');
      if (response.statusCode == 204) return;

      debugPrint(
        'removeFromCart error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    } catch (e) {
      debugPrint('removeFromCart exception: $e');
      throw Exception('Erreur réseau lors de la suppression: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final cart = await fetchCart();
      if (cart == null) return;

      for (final item in cart.items) {
        await removeFromCart(item.id);
      }
    } catch (e) {
      throw Exception('Erreur lors du vidage du panier: $e');
    }
  }

  Future<Cart> getOrCreateCart() async {
    try {
      return await createCart();
    } catch (e) {
      throw Exception('Erreur lors de la récupération/création du panier: $e');
    }
  }
}
