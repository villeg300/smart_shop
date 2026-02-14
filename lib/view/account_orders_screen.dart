import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/order_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/home_screen.dart';

class AccountOrdersScreen extends StatefulWidget {
  const AccountOrdersScreen({super.key});

  @override
  State<AccountOrdersScreen> createState() => _AccountOrdersScreenState();
}

class _AccountOrdersScreenState extends State<AccountOrdersScreen> {
  late final OrderController _orderController;
  _OrderFilter _filter = _OrderFilter.all;

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
      case _OrderFilter.all:
        return orders;
      case _OrderFilter.active:
        return orders
            .where((order) => !order.isDelivered && !order.isCancelled)
            .toList();
      case _OrderFilter.history:
        return orders
            .where((order) => order.isDelivered || order.isCancelled)
            .toList();
      case _OrderFilter.pending:
        return orders.where((order) => order.isPending).toList();
      case _OrderFilter.delivered:
        return orders.where((order) => order.isDelivered).toList();
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

  Color _statusColor(BuildContext context, Order order) {
    if (order.isDelivered) {
      return Colors.green;
    }
    if (order.isCancelled) {
      return Colors.red;
    }
    if (order.isShipped) {
      return Colors.blue;
    }
    if (order.isProcessing || order.isConfirmed) {
      return Colors.orange;
    }
    return Theme.of(context).primaryColor;
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
              "Annuler la commande",
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Etes-vous sûr de vouloir annuler cette commande ?",
              textAlign: TextAlign.center,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color,
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Non',
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Oui, annuler',
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium,
                        Colors.white,
                      ),
                    ),
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
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${order.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Statut: ${order.statusDisplay}'),
                Text('Date: ${_formatDate(order.createdAt)}'),
                const SizedBox(height: 12),
                const Text(
                  'Articles',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('x${item.quantity}'),
                        const SizedBox(width: 8),
                        Text('${item.formattedLineTotal} FCFA'),
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

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

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
        title: const Text('Mes commandes'),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _OrderFilter.values.map((item) {
                        final selected = item == _filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(item.label),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _filter = item;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
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
                        child: ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final statusColor = _statusColor(context, order);

                            return InkWell(
                              onTap: () => _showOrderDetails(order),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '#${order.id}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            order.statusDisplay,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Date: ${_formatDate(order.createdAt)}',
                                    ),
                                    Text('Articles: ${order.itemsCount}'),
                                    Text('Total: ${order.formattedTotal} FCFA'),
                                    if (order.canBeCancelled) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () =>
                                              _confirmCancel(order),
                                          icon: const Icon(
                                            Icons.cancel_outlined,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          label: const Text(
                                            'Annuler',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
  all('Toutes'),
  active('Actives'),
  history('Historique'),
  pending('En attente'),
  delivered('Livrées'),
  cancelled('Annulées');

  final String label;
  const _OrderFilter(this.label);
}
