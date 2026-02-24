import 'dart:convert';

import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/services/api_client.dart';

class AdminOrderService {
  AdminOrderService(this._client);

  final ApiClient _client;

  Future<List<Order>> fetchOrders({
    String? status,
    String? query,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
    };

    final uri = Uri.parse(
      '${_client.baseUrl}/api/shop/admin/orders/',
    ).replace(queryParameters: params);
    final response = await _client.get(
      uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement des commandes admin: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      return (decoded['results'] as List<dynamic>)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Format de réponse admin orders inattendu');
  }

  Future<Order> fetchOrderById(String orderId) async {
    final response = await _client.get('/api/shop/admin/orders/$orderId/');
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement de la commande admin: ${response.statusCode}',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
    String? adminNotes,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (adminNotes != null) {
      body['admin_notes'] = adminNotes;
    }

    final response = await _client.patch(
      '/api/shop/admin/orders/$orderId/',
      body,
    );
    if (response.statusCode != 200) {
      String message = 'Erreur mise à jour statut: ${response.statusCode}';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = err['detail']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Order.fromJson(data);
  }
}
