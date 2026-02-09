import 'dart:convert';
import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  OrderService(this._client);

  final ApiClient _client;

  /// Récupérer toutes les commandes de l'utilisateur
  Future<List<Order>> fetchOrders({int page = 1}) async {
    try {
      final params = <String, String>{'page': page.toString()};

      final uri = Uri.parse(
        '${_client.baseUrl}/api/shop/orders/',
      ).replace(queryParameters: params);

      final response = await _client.get(
        uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final orders = (data['results'] as List<dynamic>)
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();

        return orders;
      } else {
        throw Exception(
          'Erreur lors du chargement des commandes: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement des commandes: $e');
    }
  }

  /// Récupérer une commande par son ID
  Future<Order> fetchOrderById(String orderId) async {
    try {
      final response = await _client.get('/api/shop/orders/$orderId/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Order.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Commande non trouvée');
      } else {
        throw Exception(
          'Erreur lors du chargement de la commande: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement de la commande: $e');
    }
  }

  /// Passer une commande (checkout)
  Future<Order> checkout({
    required String cartId,
    double shippingCost = 0,
    String customerNotes = '',
  }) async {
    try {
      final body = {
        'cart_id': cartId,
        'shipping_cost': shippingCost,
        'customer_notes': customerNotes,
      };

      final response = await _client.post('/api/shop/checkout/', body);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Order.fromJson(data);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Erreur lors de la commande');
      } else {
        throw Exception('Erreur lors de la commande: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de la commande: $e');
    }
  }

  /// Annuler une commande
  Future<Order> cancelOrder(String orderId, {String reason = ''}) async {
    try {
      final body = {'reason': reason};

      final response = await _client.post(
        '/api/shop/orders/$orderId/cancel/',
        body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Order.fromJson(data);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? 'Impossible d\'annuler cette commande',
        );
      } else {
        throw Exception('Erreur lors de l\'annulation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de l\'annulation: $e');
    }
  }

  /// Récupérer l'historique des commandes triées par statut
  Future<Map<OrderStatus, List<Order>>> fetchOrdersByStatus() async {
    try {
      final allOrders = await fetchOrders();

      final ordersByStatus = <OrderStatus, List<Order>>{
        OrderStatus.pending: [],
        OrderStatus.confirmed: [],
        OrderStatus.processing: [],
        OrderStatus.shipped: [],
        OrderStatus.delivered: [],
        OrderStatus.cancelled: [],
      };

      for (final order in allOrders) {
        ordersByStatus[order.status]?.add(order);
      }

      return ordersByStatus;
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes par statut: $e');
    }
  }

  /// Récupérer les commandes en cours (non livrées, non annulées)
  Future<List<Order>> fetchActiveOrders() async {
    try {
      final allOrders = await fetchOrders();

      return allOrders
          .where((order) => !order.isDelivered && !order.isCancelled)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes actives: $e');
    }
  }

  /// Récupérer l'historique (commandes livrées ou annulées)
  Future<List<Order>> fetchOrderHistory() async {
    try {
      final allOrders = await fetchOrders();

      return allOrders
          .where((order) => order.isDelivered || order.isCancelled)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'historique: $e');
    }
  }
}
