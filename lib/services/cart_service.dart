import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../models/cart.dart';
import 'api_client.dart';

class CartService {
  CartService(this._client);

  final ApiClient _client;

  /// Récupérer le panier de l'utilisateur
  Future<Cart?> fetchCart() async {
    try {
      final response = await _client.get('/api/shop/carts/');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // L'API peut retourner une liste ou un objet paginé
        if (decoded is List) {
          if (decoded.isEmpty) return null;
          return Cart.fromJson(decoded.first as Map<String, dynamic>);
        }

        if (decoded is Map<String, dynamic>) {
          if (decoded['results'] is List &&
              (decoded['results'] as List).isNotEmpty) {
            return Cart.fromJson(
              (decoded['results'] as List).first as Map<String, dynamic>,
            );
          }
          if (decoded.isNotEmpty) {
            return Cart.fromJson(decoded);
          }
          return null;
        }

        throw Exception('Reponse panier inattendue: ${decoded.runtimeType}');
      } else if (response.statusCode == 404) {
        return null;
      } else {
        debugPrint('fetchCart error ${response.statusCode}: ${response.body}');
        throw Exception(
          'Erreur lors du chargement du panier: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('fetchCart exception: $e');
      throw Exception('Erreur reseau lors du chargement du panier: $e');
    }
  }

  /// Créer un panier (idempotent côté backend: 201 si créé, 200 si existant)
  Future<Cart> createCart() async {
    try {
      final response = await _client.post('/api/shop/carts/', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cart.fromJson(data);
      }

      debugPrint('createCart error ${response.statusCode}: ${response.body}');
      throw Exception(
        'Erreur lors de la creation du panier: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('createCart exception: $e');
      throw Exception('Erreur reseau lors de la creation du panier: $e');
    }
  }

  /// Ajouter un article au panier
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
      } else if (response.statusCode == 400) {
        debugPrint('addToCart 400: ${response.body}');
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Erreur lors de l\'ajout au panier');
      } else {
        debugPrint('addToCart error ${response.statusCode}: ${response.body}');
        throw Exception(
          'Erreur lors de l\'ajout au panier: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('addToCart exception: $e');
      throw Exception('Erreur reseau lors de l\'ajout au panier: $e');
    }
  }

  /// Mettre à jour la quantité d'un article
  Future<CartItem> updateCartItem({
    required String itemId,
    required String cartId,
    required String variantId,
    required int quantity,
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

      final response = await _client.put('/api/shop/cart-items/$itemId/', body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CartItem.fromJson(data);
      }

      debugPrint(
        'updateCartItem error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Erreur lors de la mise a jour: ${response.statusCode}');
    } catch (e) {
      debugPrint('updateCartItem exception: $e');
      throw Exception('Erreur reseau lors de la mise a jour: $e');
    }
  }

  /// Supprimer un article du panier
  Future<bool> removeFromCart(String itemId) async {
    try {
      final response = await _client.delete('/api/shop/cart-items/$itemId/');

      if (response.statusCode == 204) {
        return true;
      }

      debugPrint(
        'removeFromCart error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    } catch (e) {
      debugPrint('removeFromCart exception: $e');
      throw Exception('Erreur reseau lors de la suppression: $e');
    }
  }

  /// Vider le panier
  Future<bool> clearCart(String cartId) async {
    try {
      final cart = await fetchCart();
      if (cart == null) return true;

      for (final item in cart.items) {
        await removeFromCart(item.id);
      }

      return true;
    } catch (e) {
      throw Exception('Erreur lors du vidage du panier: $e');
    }
  }

  /// Obtenir ou créer un panier pour l'utilisateur courant
  Future<Cart> getOrCreateCart() async {
    try {
      return await createCart();
    } catch (e) {
      throw Exception('Erreur lors de la recuperation/creation du panier: $e');
    }
  }
}
