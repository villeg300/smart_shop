import 'variant.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.processing:
        return 'En traitement';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final Variant? variant;
  final int quantity;
  final double priceSnapshot;
  final String skuSnapshot;
  final String nameSnapshot;

  OrderItem({
    required this.id,
    required this.orderId,
    this.variant,
    required this.quantity,
    required this.priceSnapshot,
    required this.skuSnapshot,
    required this.nameSnapshot,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order'] as String,
      variant: json['variant'] != null
          ? Variant.fromJson(json['variant'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] as int,
      priceSnapshot: double.parse(json['price_snapshot'].toString()),
      skuSnapshot: json['sku_snapshot'] as String,
      nameSnapshot: json['name_snapshot'] as String,
    );
  }

  double get lineTotal => priceSnapshot * quantity;

  String get formattedLineTotal {
    final total = lineTotal.toStringAsFixed(0);
    return total.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String get displayName => nameSnapshot;

  @override
  String toString() => 'OrderItem(name: $nameSnapshot, qty: $quantity)';
}

class Order {
  final String id;
  final String userId;
  final OrderStatus status;
  final double subtotal;
  final double shippingCost;
  final double discountAmount;
  final double totalAmount;
  final String customerNotes;
  final String adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final List<OrderItem> items;

  // Propriétés calculées
  final String formattedTotal;
  final String formattedSubtotal;
  final String formattedShipping;
  final int itemsCount;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.discountAmount,
    required this.totalAmount,
    this.customerNotes = '',
    this.adminNotes = '',
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.items,
    required this.formattedTotal,
    required this.formattedSubtotal,
    required this.formattedShipping,
    required this.itemsCount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList =
        (json['items'] as List<dynamic>?)
            ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Order(
      id: json['id'] as String,
      userId: json['user'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      subtotal: double.parse(json['subtotal'].toString()),
      shippingCost: double.parse(json['shipping_cost'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      customerNotes: json['customer_notes'] as String? ?? '',
      adminNotes: json['admin_notes'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      items: itemsList,
      formattedTotal: json['formatted_total'] as String? ?? '0',
      formattedSubtotal: json['formatted_subtotal'] as String? ?? '0',
      formattedShipping: json['formatted_shipping'] as String? ?? '0',
      itemsCount: json['items_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'status': status.name,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'customer_notes': customerNotes,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == OrderStatus.pending;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isProcessing => status == OrderStatus.processing;
  bool get isShipped => status == OrderStatus.shipped;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  bool get canBeCancelled =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.processing;

  String get statusDisplay => status.displayName;

  Order copyWith({
    String? id,
    String? userId,
    OrderStatus? status,
    double? subtotal,
    double? shippingCost,
    double? discountAmount,
    double? totalAmount,
    String? customerNotes,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    List<OrderItem>? items,
    String? formattedTotal,
    String? formattedSubtotal,
    String? formattedShipping,
    int? itemsCount,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      customerNotes: customerNotes ?? this.customerNotes,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      items: items ?? this.items,
      formattedTotal: formattedTotal ?? this.formattedTotal,
      formattedSubtotal: formattedSubtotal ?? this.formattedSubtotal,
      formattedShipping: formattedShipping ?? this.formattedShipping,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }

  @override
  String toString() =>
      'Order(id: $id, status: ${status.name}, total: $formattedTotal)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
