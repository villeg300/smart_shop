import 'package:flutter/material.dart';
import 'package:smart_shop/models/order.dart';

class OrderStatusConstants {
  OrderStatusConstants._();

  // Ces statuts sont alignés 1:1 avec le backend Django (store.models.Order.STATUS_CHOICES).
  static const List<OrderStatus> backendStatuses = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.pickedUp,
    OrderStatus.cancelled,
  ];

  // Bloc statistique principal demandé dans la wireframe.
  static const List<OrderStatus> statsStatuses = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.pickedUp,
  ];

  static String backendValue(OrderStatus status) => status.backendValue;

  static String label(OrderStatus status) => status.displayName;

  // Règles alignées avec le backend:
  // shopper: annulation autorisée uniquement en attente / en traitement.
  static bool canShopperCancel(OrderStatus status) =>
      status == OrderStatus.pending || status == OrderStatus.processing;

  // admin: annulation interdite sur pickedUp et cancelled.
  static bool canAdminCancel(OrderStatus status) =>
      status == OrderStatus.pending ||
      status == OrderStatus.processing ||
      status == OrderStatus.ready;

  static List<OrderStatus> adminEditableStatuses(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:
        return const <OrderStatus>[
          OrderStatus.pending,
          OrderStatus.processing,
          OrderStatus.cancelled,
        ];
      case OrderStatus.processing:
        return const <OrderStatus>[
          OrderStatus.processing,
          OrderStatus.ready,
          OrderStatus.cancelled,
        ];
      case OrderStatus.ready:
        return const <OrderStatus>[
          OrderStatus.ready,
          OrderStatus.pickedUp,
          OrderStatus.cancelled,
        ];
      case OrderStatus.pickedUp:
        return const <OrderStatus>[OrderStatus.pickedUp];
      case OrderStatus.cancelled:
        return const <OrderStatus>[OrderStatus.cancelled];
    }
  }

  static bool canAdminEditStatus(OrderStatus current) =>
      adminEditableStatuses(current).any((status) => status != current);

  static IconData icon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule_outlined;
      case OrderStatus.processing:
        return Icons.sync_outlined;
      case OrderStatus.ready:
        return Icons.local_shipping_outlined;
      case OrderStatus.pickedUp:
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
      case OrderStatus.processing:
        return StatusVisual(
          background: Colors.green.withValues(alpha: 0.16),
          foreground: Colors.green.shade800,
        );
      case OrderStatus.ready:
        return StatusVisual(
          background: Colors.blue.withValues(alpha: 0.14),
          foreground: Colors.blue.shade800,
        );
      case OrderStatus.pickedUp:
        return StatusVisual(
          background: Colors.indigo.withValues(alpha: 0.16),
          foreground: Colors.indigo.shade700,
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
