import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_shop/controllers/order_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/home_screen.dart';
import 'package:smart_shop/view/widgets/order_ticket.dart';

class AccountOrdersScreen extends StatefulWidget {
  const AccountOrdersScreen({super.key});

  @override
  State<AccountOrdersScreen> createState() => _AccountOrdersScreenState();
}

class _AccountOrdersScreenState extends State<AccountOrdersScreen> {
  late final OrderController _orderController;
  _OrderFilter _filter = _OrderFilter.active;

  @override
  void initState() {
    super.initState();
    _orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    _orderController.loadOrders();
  }

  Future<void> _refresh() async {
    await _orderController.loadOrders();
  }

  List<Order> _applyFilter(List<Order> orders) {
    switch (_filter) {
      case _OrderFilter.active:
        return orders
            .where((order) => !order.isDelivered && !order.isCancelled)
            .toList();
      case _OrderFilter.pending:
        return orders.where((order) => order.isPending).toList();
      case _OrderFilter.confirmed:
        return orders.where((order) => order.isConfirmed).toList();
      case _OrderFilter.cancelled:
        return orders.where((order) => order.isCancelled).toList();
    }
  }

  String _formatDate(DateTime date) {
    const months = <int, String>{
      1: 'Jan',
      2: 'Fev',
      3: 'Mar',
      4: 'Avr',
      5: 'Mai',
      6: 'Juin',
      7: 'Juil',
      8: 'Aou',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    final month = months[date.month] ?? '${date.month}';
    return '${date.day} $month ${date.year}';
  }

  String _formatPickup(Order order) {
    final date = order.pickupDate?.trim() ?? '';
    final time = order.pickupTime?.trim() ?? '';

    if (date.isEmpty && time.isEmpty) {
      final created = order.createdAt;
      final hh = created.hour.toString().padLeft(2, '0');
      final mm = created.minute.toString().padLeft(2, '0');
      return '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} a $hh:$mm';
    }

    final shortTime = time.length >= 5 ? time.substring(0, 5) : time;
    if (date.isNotEmpty && shortTime.isNotEmpty) {
      return '$date a $shortTime';
    }
    return date.isNotEmpty ? date : shortTime;
  }

  Future<void> _confirmCancel(Order order) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: 32,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Annuler la commande',
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Êtes-vous sûr de vouloir annuler cette commande ?',
              textAlign: TextAlign.center,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Non'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                    child: const Text('Oui, annuler'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );

    if (confirm == true) {
      await _orderController.cancelOrder(order.id);
      await _orderController.loadOrders();
    }
  }

  void _showOrderDetails(Order order) {
    final theme = Theme.of(context);
    final statusColor = _statusChipColor(order);

    Get.bottomSheet(
      FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Détail commande',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.withWeight(
                    AppTextStyles.h3,
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _OrderStatusPill(
                                    label: order.statusDisplay,
                                    color: statusColor,
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _DetailLine(
                                icon: Icons.store_mall_directory_outlined,
                                text: 'Retrait: ${_formatPickup(order)}',
                              ),
                              if (order.customerNotes.trim().isNotEmpty)
                                _DetailLine(
                                  icon: Icons.notes_outlined,
                                  text: order.customerNotes.trim(),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Container(
                            width: 230,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: order.id,
                                  size: 150,
                                  version: QrVersions.auto,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  order.id,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Articles (${order.items.length})',
                          style: AppTextStyles.withWeight(
                            AppTextStyles.h3,
                            FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...order.items.map(
                          (item) => _OrderDetailItemCard(item: item),
                        ),
                        const SizedBox(height: 10),
                        if (order.canBeCancelled)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                Get.back();
                                await _confirmCancel(order);
                              },
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Annuler la commande'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(
                                  color: Colors.red.withValues(alpha: 0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Color _statusChipColor(Order order) {
    if (order.isCancelled) return Colors.red;
    if (order.isDelivered || order.isConfirmed) return Colors.green;
    if (order.isPending) return Colors.grey.shade700;
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back();
            } else {
              Get.offAll(() => const HomeScreen());
            }
          },
        ),
        title: const Text('Commandes'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: Padding(
              padding: padding,
              child: Column(
                children: [
                  DropdownButtonFormField<_OrderFilter>(
                    initialValue: _filter,
                    decoration: InputDecoration(
                      labelText: 'Filtrer',
                      prefixIcon: const Icon(Icons.filter_alt_outlined),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _OrderFilter.values
                        .map(
                          (filter) => DropdownMenuItem<_OrderFilter>(
                            value: filter,
                            child: Text(filter.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _filter = value;
                      });
                    },
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: Obx(() {
                      if (_orderController.isLoadingOrders.value &&
                          _orderController.orders.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final orders = _applyFilter(_orderController.orders);
                      if (orders.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView(
                            children: const [
                              SizedBox(height: 120),
                              Icon(Icons.receipt_long, size: 70),
                              SizedBox(height: 12),
                              Center(
                                child: Text('Aucune commande pour ce filtre'),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return OrderTicket(
                              order: order,
                              onTap: () => _showOrderDetails(order),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _OrderFilter {
  active('Actives'),
  pending('En attente'),
  confirmed('Confirmée'),
  cancelled('Annulées');

  final String label;
  const _OrderFilter(this.label);
}

class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailItemCard extends StatelessWidget {
  const _OrderDetailItemCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = item.variant?.imageUrl;
    final attributesText = _resolveAttributes(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 58,
              height: 58,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.6,
              ),
              child: (imageUrl != null && imageUrl.trim().isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      color: theme.colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (attributesText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      attributesText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.formattedLineTotal} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _resolveAttributes(OrderItem item) {
    final variant = item.variant;
    if (variant == null) {
      return item.skuSnapshot.isNotEmpty ? 'SKU: ${item.skuSnapshot}' : '';
    }

    if (variant.attributesDisplay.trim().isNotEmpty) {
      return variant.attributesDisplay.trim();
    }

    if (variant.attributes.isNotEmpty) {
      return variant.attributes
          .map((a) => '${a.attributeName}: ${a.value}')
          .join(' • ');
    }

    if (item.skuSnapshot.isNotEmpty) {
      return 'SKU: ${item.skuSnapshot}';
    }

    return '';
  }
}
