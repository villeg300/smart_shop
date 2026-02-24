import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  'Detail commande',
                  style: AppTextStyles.withWeight(
                    AppTextStyles.h3,
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Statut: ${order.statusDisplay}'),
                Text('Date: ${_formatDate(order.createdAt)}'),
                Text('Retrait: ${_formatPickup(order)}'),
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
                const SizedBox(height: 8),
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
