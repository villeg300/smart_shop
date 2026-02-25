import 'package:flutter/material.dart';
import 'package:smart_shop/models/order.dart';

class OrderStatusConstants {
  OrderStatusConstants._();

  // Ces statuts sont alignés 1:1 avec le backend Django (store.models.Order.STATUS_CHOICES).
  static const List<OrderStatus> backendStatuses = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  // Bloc statistique principal demandé dans la wireframe.
  static const List<OrderStatus> statsStatuses = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.delivered,
    OrderStatus.confirmed,
  ];

  static String backendValue(OrderStatus status) => status.name;

  static String label(OrderStatus status) => status.displayName;

  static IconData icon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule_outlined;
      case OrderStatus.confirmed:
        return Icons.verified_outlined;
      case OrderStatus.processing:
        return Icons.sync_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.inventory_2_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static StatusVisual visual(BuildContext context, OrderStatus status) {
    final scheme = Theme.of(context).colorScheme;

    switch (status) {
      case OrderStatus.pending:
        return StatusVisual(
          background: scheme.surfaceContainerHighest,
          foreground: scheme.onSurfaceVariant,
        );
      case OrderStatus.confirmed:
        return StatusVisual(
          background: Colors.green.withValues(alpha: 0.16),
          foreground: Colors.green.shade800,
        );
      case OrderStatus.processing:
        return StatusVisual(
          background: Colors.blue.withValues(alpha: 0.14),
          foreground: Colors.blue.shade800,
        );
      case OrderStatus.shipped:
        return StatusVisual(
          background: Colors.indigo.withValues(alpha: 0.16),
          foreground: Colors.indigo.shade700,
        );
      case OrderStatus.delivered:
        return StatusVisual(
          background: Colors.teal.withValues(alpha: 0.16),
          foreground: Colors.teal.shade800,
        );
      case OrderStatus.cancelled:
        return StatusVisual(
          background: scheme.errorContainer.withValues(alpha: 0.76),
          foreground: scheme.onErrorContainer,
        );
    }
  }
}

class StatusVisual {
  const StatusVisual({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
