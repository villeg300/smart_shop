import 'variant.dart';

class CartItem {
  final String id;
  final String cartId;
  final Variant variant;
  final int quantity;
  final double unitPrice;

  CartItem({
    required this.id,
    required this.cartId,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      cartId: json['cart'] as String,
      variant: Variant.fromJson(json['variant'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart': cartId,
      'variant_id': variant.id,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  double get lineTotal => unitPrice * quantity;

  String get formattedLineTotal {
    final total = lineTotal.toStringAsFixed(0);
    return total.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  CartItem copyWith({
    String? id,
    String? cartId,
    Variant? variant,
    int? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  String toString() =>
      'CartItem(variant: ${variant.displayName}, qty: $quantity)';
}

class Cart {
  final String id;
  final String userId;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList =
        (json['items'] as List<dynamic>?)
            ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Cart(
      id: json['id'] as String,
      userId: json['user'].toString(),
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get calculatedTotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  String get formattedTotal {
    final total = calculatedTotal.toStringAsFixed(0);
    return total.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    String? id,
    String? userId,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CartItem>? items,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  String toString() =>
      'Cart(id: $id, items: ${items.length}, total: $formattedTotal)';
}
