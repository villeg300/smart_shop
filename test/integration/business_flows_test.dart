import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:smart_shop/services/api_client.dart';
import 'package:smart_shop/services/auth_service.dart';
import 'package:smart_shop/services/cart_service.dart';
import 'package:smart_shop/services/catalog_service.dart';
import 'package:smart_shop/services/favorite_service.dart';
import 'package:smart_shop/services/order_service.dart';

class FakeApiClient implements ApiClient {
  @override
  String get baseUrl => 'http://fake.local';

  String? _accessToken;
  String? _refreshToken;
  int _cartItemSeq = 1;
  int _orderSeq = 1;

  final DateTime _now = DateTime(2026, 2, 25, 12, 0, 0);

  final Map<String, dynamic> _user = <String, dynamic>{
    'id': 1,
    'phone_number': '+22670000001',
    'full_name': 'Client Test',
    'email': 'client@example.com',
    'loyalty_points': 0,
    'is_staff': false,
    'is_superuser': false,
    'date_joined': '2026-02-01T10:00:00Z',
    'avatar': null,
  };

  late final List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Telephones',
      'slug': 'telephones',
      'is_active': true,
      'created_at': _now.toIso8601String(),
      'product_count': 1,
    },
    <String, dynamic>{
      'name': 'Audio',
      'slug': 'audio',
      'is_active': true,
      'created_at': _now.toIso8601String(),
      'product_count': 1,
    },
  ];

  late final List<Map<String, dynamic>> _products = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'SS-PDT-1',
      'name': 'Phone X',
      'slug': 'phone-x',
      'brand': 'Smart',
      'model': 'X',
      'category': _categories[0],
      'generic_image': null,
      'description': 'Smart phone',
      'is_active': true,
      'created_at': _now.toIso8601String(),
      'updated_at': _now.toIso8601String(),
      'min_price': '250000',
      'max_price': '250000',
      'price_range': '250000',
      'total_stock': 12,
      'is_in_stock': true,
      'has_promotion': false,
    },
    <String, dynamic>{
      'id': 'SS-PDT-2',
      'name': 'Headset Pro',
      'slug': 'headset-pro',
      'brand': 'Smart',
      'model': 'H1',
      'category': _categories[1],
      'generic_image': null,
      'description': 'Headset',
      'is_active': true,
      'created_at': _now.toIso8601String(),
      'updated_at': _now.toIso8601String(),
      'min_price': '60000',
      'max_price': '60000',
      'price_range': '60000',
      'total_stock': 30,
      'is_in_stock': true,
      'has_promotion': true,
    },
  ];

  late final Map<String, Map<String, dynamic>> _variantsById =
      <String, Map<String, dynamic>>{
        'SS-VRT-1': _variantJson(
          id: 'SS-VRT-1',
          product: _products[0],
          price: 250000,
          stock: 12,
          hasPromotion: false,
        ),
        'SS-VRT-2': _variantJson(
          id: 'SS-VRT-2',
          product: _products[1],
          price: 60000,
          stock: 30,
          hasPromotion: true,
        ),
      };

  final Set<String> _favoriteProductIds = <String>{};
  final List<Map<String, dynamic>> _orders = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _cartItems = <Map<String, dynamic>>[];
  Map<String, dynamic>? _cart;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  bool get isAuthenticated => _accessToken != null && _refreshToken != null;

  @override
  void saveTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  @override
  void saveAccessToken(String access) {
    _accessToken = access;
  }

  @override
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    if (uri.path == '/api/auth/users/me/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      return _json(200, _user);
    }

    if (uri.path == '/api/shop/categories/') {
      return _json(200, _categories);
    }

    if (uri.path == '/api/shop/products/') {
      final categorySlug = uri.queryParameters['category_slug'];
      final query = uri.queryParameters['q']?.toLowerCase();
      final products = _products.where((product) {
        if (categorySlug != null && categorySlug.isNotEmpty) {
          final category = product['category'] as Map<String, dynamic>;
          if (category['slug'] != categorySlug) return false;
        }
        if (query != null && query.isNotEmpty) {
          final name = (product['name'] as String).toLowerCase();
          final brand = (product['brand'] as String).toLowerCase();
          return name.contains(query) || brand.contains(query);
        }
        return true;
      }).toList();

      return _json(200, <String, dynamic>{
        'count': products.length,
        'next': null,
        'previous': null,
        'results': products,
      });
    }

    if (uri.path == '/api/shop/variants/') {
      final productId = uri.queryParameters['product'];
      final variants = _variantsById.values.where((variant) {
        if (productId == null || productId.isEmpty) {
          return true;
        }
        final product = variant['product'] as Map<String, dynamic>;
        return product['id'] == productId;
      }).toList();

      return _json(200, <String, dynamic>{
        'count': variants.length,
        'next': null,
        'previous': null,
        'results': variants,
      });
    }

    if (uri.path == '/api/shop/favorites/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final favorites = _favoriteProductIds.map((productId) {
        return <String, dynamic>{
          'id': 'SS-FAV-$productId',
          'product': _productById(productId),
          'created_at': _now.toIso8601String(),
        };
      }).toList();
      return _json(200, favorites);
    }

    if (uri.path == '/api/shop/carts/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      if (_cart == null) {
        return _json(404, <String, dynamic>{'detail': 'Panier introuvable'});
      }
      return _json(200, _cartResponse());
    }

    if (uri.path == '/api/shop/orders/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      return _json(200, <String, dynamic>{
        'count': _orders.length,
        'next': null,
        'previous': null,
        'results': _orders,
      });
    }

    if (uri.path.startsWith('/api/shop/orders/') && uri.path.endsWith('/')) {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final orderId = uri.pathSegments[3];
      final order = _findById(_orders, orderId);
      if (order == null) {
        return _json(404, <String, dynamic>{'detail': 'Commande introuvable'});
      }
      return _json(200, order);
    }

    return _json(404, <String, dynamic>{'detail': 'Not found'});
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    if (uri.path == '/api/auth/jwt/create/') {
      return _json(200, <String, dynamic>{
        'access': 'access-token',
        'refresh': 'refresh-token',
        'user': _user,
      });
    }

    if (uri.path == '/api/shop/favorites/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final productId = body['product_id']?.toString();
      if (productId == null || _productById(productId) == null) {
        return _json(400, <String, dynamic>{'detail': 'Produit invalide.'});
      }
      final created = _favoriteProductIds.add(productId);
      return _json(created ? 201 : 200, <String, dynamic>{
        'id': 'SS-FAV-$productId',
        'product': _productById(productId),
        'created_at': _now.toIso8601String(),
      });
    }

    if (uri.path == '/api/shop/carts/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final created = _cart == null;
      _cart ??= <String, dynamic>{
        'id': 'SS-CRT-1',
        'user': 1,
        'created_at': _now.toIso8601String(),
        'updated_at': _now.toIso8601String(),
      };
      return _json(created ? 201 : 200, _cartResponse());
    }

    if (uri.path == '/api/shop/cart-items/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final cartId = body['cart']?.toString();
      if (_cart == null || _cart!['id'] != cartId) {
        return _json(400, <String, dynamic>{'detail': 'Panier invalide.'});
      }
      final variantId = body['variant_id']?.toString() ?? '';
      final variant = _variantsById[variantId];
      if (variant == null) {
        return _json(400, <String, dynamic>{'detail': 'Variante invalide.'});
      }
      final quantity = body['quantity'] as int? ?? 1;
      final unitPrice =
          (body['unit_price'] as num?)?.toDouble() ??
          (variant['final_price'] as num).toDouble();
      final item = <String, dynamic>{
        'id': 'SS-CTI-${_cartItemSeq++}',
        'cart': _cart!['id'],
        'variant': variant,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
      _cartItems.add(item);
      return _json(201, item);
    }

    if (uri.path == '/api/shop/checkout/') {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      if (_cart == null || body['cart_id']?.toString() != _cart!['id']) {
        return _json(400, <String, dynamic>{'detail': 'Panier invalide.'});
      }
      if (_cartItems.isEmpty) {
        return _json(400, <String, dynamic>{'detail': 'Panier vide.'});
      }

      final shippingCost = (body['shipping_cost'] as num?)?.toDouble() ?? 0;
      final subtotal = _cartItems.fold<double>(
        0,
        (sum, item) =>
            sum +
            ((item['unit_price'] as num).toDouble() *
                (item['quantity'] as int).toDouble()),
      );
      final total = subtotal + shippingCost;
      final orderId = 'SS-ODR-${_orderSeq++}';
      final orderItems = _cartItems.map((item) {
        final variant = item['variant'] as Map<String, dynamic>;
        return <String, dynamic>{
          'id': 'SS-ODI-${item['id']}',
          'order': orderId,
          'variant': null,
          'quantity': item['quantity'],
          'price_snapshot': item['unit_price'],
          'sku_snapshot': variant['sku'] ?? '',
          'name_snapshot': variant['full_name'],
        };
      }).toList();
      final itemsCount = _cartItems.fold<int>(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );

      final order = <String, dynamic>{
        'id': orderId,
        'user': 1,
        'user_full_name': _user['full_name'],
        'user_phone_number': _user['phone_number'],
        'user_email': _user['email'],
        'status': 'pending',
        'subtotal': subtotal,
        'shipping_cost': shippingCost,
        'discount_amount': 0,
        'total_amount': total,
        'customer_notes': body['customer_notes']?.toString() ?? '',
        'admin_notes': '',
        'pickup_date': body['pickup_date'],
        'pickup_time': body['pickup_time'],
        'created_at': _now.toIso8601String(),
        'updated_at': _now.toIso8601String(),
        'confirmed_at': null,
        'shipped_at': null,
        'delivered_at': null,
        'cancelled_at': null,
        'formatted_total': total.toStringAsFixed(0),
        'formatted_subtotal': subtotal.toStringAsFixed(0),
        'formatted_shipping': shippingCost.toStringAsFixed(0),
        'items_count': itemsCount,
        'items': orderItems,
      };
      _orders.insert(0, order);

      _cart = null;
      _cartItems.clear();

      return _json(201, order);
    }

    if (uri.path.startsWith('/api/shop/orders/') &&
        uri.path.endsWith('/cancel/')) {
      // Forcer le fallback PATCH dans OrderService.cancelOrder.
      return _json(404, <String, dynamic>{'detail': 'Not found'});
    }

    return _json(404, <String, dynamic>{'detail': 'Not found'});
  }

  @override
  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');

    if (uri.path.startsWith('/api/shop/cart-items/') &&
        uri.path.endsWith('/')) {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final itemId = uri.pathSegments[3];
      final item = _findById(_cartItems, itemId);
      if (item == null) {
        return _json(404, <String, dynamic>{'detail': 'Item introuvable'});
      }
      item['quantity'] = body['quantity'] as int? ?? item['quantity'];
      if (body['unit_price'] != null) {
        item['unit_price'] = (body['unit_price'] as num).toDouble();
      }
      return _json(200, item);
    }

    if (uri.path.startsWith('/api/shop/orders/') && uri.path.endsWith('/')) {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final orderId = uri.pathSegments[3];
      final order = _findById(_orders, orderId);
      if (order == null) {
        return _json(404, <String, dynamic>{'detail': 'Commande introuvable'});
      }
      final status = body['status']?.toString();
      if (status == 'cancelled') {
        order['status'] = 'cancelled';
        order['cancelled_at'] = _now.toIso8601String();
        order['updated_at'] = _now.toIso8601String();
      }
      return _json(200, order);
    }

    return _json(404, <String, dynamic>{'detail': 'Not found'});
  }

  @override
  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    if (uri.path.startsWith('/api/shop/favorites/product/') &&
        uri.path.endsWith('/')) {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final productId = uri.pathSegments[4];
      _favoriteProductIds.remove(productId);
      return _noContent();
    }

    if (uri.path.startsWith('/api/shop/cart-items/') &&
        uri.path.endsWith('/')) {
      if (!_isAuthed()) {
        return _json(401, <String, dynamic>{'detail': 'Unauthorized'});
      }
      final itemId = uri.pathSegments[3];
      _cartItems.removeWhere((item) => item['id'] == itemId);
      return _noContent();
    }

    return _json(404, <String, dynamic>{'detail': 'Not found'});
  }

  @override
  Future<http.Response> put(String path, Map<String, dynamic> body) {
    return Future<http.Response>.value(
      _json(405, <String, dynamic>{'detail': 'Method not allowed'}),
    );
  }

  @override
  Future<http.Response> multipart(
    String method,
    String path, {
    Map<String, String>? fields,
    Map<String, String>? filePaths,
    bool includeAuth = true,
  }) {
    return Future<http.Response>.value(
      _json(405, <String, dynamic>{'detail': 'Method not allowed'}),
    );
  }

  @override
  Future<bool> verifyToken() {
    return Future<bool>.value(isAuthenticated);
  }

  bool _isAuthed() => _accessToken != null;

  Map<String, dynamic>? _productById(String productId) {
    for (final product in _products) {
      if (product['id'] == productId) return product;
    }
    return null;
  }

  Map<String, dynamic>? _findById(
    List<Map<String, dynamic>> source,
    String id,
  ) {
    for (final item in source) {
      if (item['id'] == id) {
        return item;
      }
    }
    return null;
  }

  Map<String, dynamic> _variantJson({
    required String id,
    required Map<String, dynamic> product,
    required double price,
    required int stock,
    required bool hasPromotion,
  }) {
    return <String, dynamic>{
      'id': id,
      'product': <String, dynamic>{
        'id': product['id'],
        'name': product['name'],
        'slug': product['slug'],
        'brand': product['brand'],
        'model': product['model'],
      },
      'sku': 'SKU-$id',
      'price': price,
      'stock': stock,
      'attributes': <dynamic>[],
      'image': null,
      'is_active': true,
      'created_at': _now.toIso8601String(),
      'promo_price': hasPromotion ? (price - 5000) : null,
      'promo_percentage': hasPromotion ? null : null,
      'attributes_display': '',
      'full_name': product['name'],
      'final_price': hasPromotion ? (price - 5000) : price,
      'old_price': hasPromotion ? price : null,
      'discount_percentage': hasPromotion ? 2 : 0,
      'formatted_price': (hasPromotion ? (price - 5000) : price)
          .toStringAsFixed(0),
      'formatted_old_price': hasPromotion ? price.toStringAsFixed(0) : null,
      'has_promotion': hasPromotion,
      'is_in_stock': stock > 0,
    };
  }

  Map<String, dynamic> _cartResponse() {
    final total = _cartItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          ((item['unit_price'] as num).toDouble() *
              (item['quantity'] as int).toDouble()),
    );
    return <String, dynamic>{
      ...?_cart,
      'total_price': total.toStringAsFixed(2),
      'items': _cartItems,
    };
  }

  http.Response _json(int statusCode, Object body) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }

  http.Response _noContent() {
    return http.Response('', 204);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Flux metier frontend (integration)', () {
    late FakeApiClient apiClient;
    late AuthService authService;
    late CatalogService catalogService;
    late FavoriteService favoriteService;
    late CartService cartService;
    late OrderService orderService;

    setUp(() {
      apiClient = FakeApiClient();
      authService = AuthService(apiClient);
      catalogService = CatalogService(apiClient);
      favoriteService = FavoriteService(apiClient);
      cartService = CartService(apiClient);
      orderService = OrderService(apiClient);
    });

    test('auth + catalogue + favoris', () async {
      final login = await authService.login(
        phoneNumber: '+22670000001',
        password: 'StrongPass123!',
      );
      expect(login.user.fullName, 'Client Test');
      expect(apiClient.isAuthenticated, true);

      final categories = await catalogService.fetchCategories();
      expect(categories.length, 2);

      final productsResult = await catalogService.fetchProducts(page: 1);
      final products = productsResult['products'] as List<dynamic>;
      expect(products.length, 2);

      final filteredResult = await catalogService.fetchProducts(
        categorySlug: 'telephones',
      );
      final filteredProducts = filteredResult['products'] as List<dynamic>;
      expect(filteredProducts.length, 1);

      await favoriteService.addFavorite('SS-PDT-1');
      final favorites = await favoriteService.fetchFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 'SS-PDT-1');

      await favoriteService.removeFavorite('SS-PDT-1');
      final favoritesAfterDelete = await favoriteService.fetchFavorites();
      expect(favoritesAfterDelete, isEmpty);
    });

    test('panier: creation, ajout, update, suppression', () async {
      await authService.login(
        phoneNumber: '+22670000001',
        password: 'StrongPass123!',
      );

      final cart = await cartService.getOrCreateCart();
      expect(cart.id, 'SS-CRT-1');

      final item = await cartService.addToCart(
        cartId: cart.id,
        variantId: 'SS-VRT-1',
        quantity: 2,
      );
      expect(item.quantity, 2);

      final updated = await cartService.updateCartItem(
        itemId: item.id,
        quantity: 4,
      );
      expect(updated.quantity, 4);

      final fetched = await cartService.fetchCart();
      expect(fetched, isNotNull);
      expect(fetched!.itemsCount, 4);

      await cartService.removeFromCart(item.id);
      final afterRemove = await cartService.fetchCart();
      expect(afterRemove, isNotNull);
      expect(afterRemove!.items, isEmpty);
    });

    test('checkout puis annulation commande', () async {
      await authService.login(
        phoneNumber: '+22670000001',
        password: 'StrongPass123!',
      );

      final cart = await cartService.getOrCreateCart();
      await cartService.addToCart(
        cartId: cart.id,
        variantId: 'SS-VRT-2',
        quantity: 1,
      );

      final order = await orderService.checkout(
        cartId: cart.id,
        pickupDate: '2030-01-01',
        pickupTime: '14:30:00',
        shippingCost: 500,
        customerNotes: 'RAS',
      );
      expect(order.isPending, true);
      expect(order.itemsCount, 1);

      final cartAfterCheckout = await cartService.fetchCart();
      expect(cartAfterCheckout, isNull);

      final orders = await orderService.fetchOrders();
      expect(orders.length, 1);
      expect(orders.first.id, order.id);

      final cancelled = await orderService.cancelOrder(order.id);
      expect(cancelled.isCancelled, true);
    });
  });
}
