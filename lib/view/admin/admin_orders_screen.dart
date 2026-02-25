import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/constants/order_status_constants.dart';
import 'package:smart_shop/controllers/admin_order_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/admin/admin_order_detail_screen.dart';
import 'package:smart_shop/view/admin/admin_scan_order_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes admin')),
      body: const AdminOrdersTab(),
    );
  }
}

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  late final AdminOrderController _controller;
  late final TextEditingController _searchController;

  OrderStatus _selectedStatus = OrderStatus.pending;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminOrderController>()
        ? Get.find<AdminOrderController>()
        : Get.put(AdminOrderController());

    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );

    final selected = _controller.selectedStatusFilter.value;
    if (selected.isNotEmpty) {
      _selectedStatus = OrderStatus.fromString(selected);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool showLoader = true}) async {
    await _controller.loadOrders(
      status: OrderStatusConstants.backendValue(_selectedStatus),
      query: _searchController.text.trim(),
      showLoader: showLoader,
    );
  }

  Future<void> _openFindScanner() async {
    await Get.to(
      () => const AdminScanOrderScreen(
        mode: AdminScanMode.find,
        title: 'Chercher une commande',
      ),
    );
    await _loadOrders(showLoader: false);
  }

  Future<void> _openPickupScanner() async {
    await Get.to(
      () => const AdminScanOrderScreen(
        mode: AdminScanMode.pickup,
        title: 'Marquer une commande récupérée',
      ),
    );
    await _loadOrders(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = AppResponsive.pagePadding(context);
    final itemSpacing = AppResponsive.itemSpacing(context);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppResponsive.contentMaxWidth(context),
          ),
          child: Padding(
            padding: pagePadding,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openFindScanner,
                        icon: const Icon(Icons.qr_code_scanner_outlined),
                        label: const Text('Chercher'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openPickupScanner,
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Récupérer'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: itemSpacing),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher (ID, client, email, téléphone)',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _loadOrders(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: _loadOrders,
                      icon: const Icon(Icons.search),
                      label: const Text('OK'),
                    ),
                  ],
                ),
                SizedBox(height: itemSpacing),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: OrderStatusConstants.backendStatuses.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status =
                          OrderStatusConstants.backendStatuses[index];
                      final isSelected = status == _selectedStatus;
                      final visual = OrderStatusConstants.visual(
                        context,
                        status,
                      );

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(OrderStatusConstants.label(status)),
                        avatar: Icon(
                          OrderStatusConstants.icon(status),
                          size: 16,
                          color: isSelected
                              ? visual.foreground
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        selectedColor: visual.background,
                        onSelected: (_) {
                          setState(() {
                            _selectedStatus = status;
                          });
                          _loadOrders();
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: itemSpacing),
                Expanded(
                  child: Obx(() {
                    final orders = _controller.orders;

                    if (_controller.isLoading.value && orders.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (orders.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => _loadOrders(showLoader: false),
                        child: ListView(
                          children: [
                            const SizedBox(height: 120),
                            Icon(
                              Icons.receipt_long,
                              size: 66,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            const Center(
                              child: Text('Aucune commande pour ce statut'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => _loadOrders(showLoader: false),
                      child: ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _AdminOrderCard(
                            order: order,
                            onTap: () => Get.to(
                              () => AdminOrderDetailScreen(orderId: order.id),
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
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = OrderStatusConstants.visual(context, order.status);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.withWeight(
                        AppTextStyles.bodyMedium,
                        FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: visual.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      OrderStatusConstants.label(order.status),
                      style: TextStyle(
                        color: visual.foreground,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoLine(
                icon: Icons.person_outline,
                text: order.userFullName ?? 'Client non renseigné',
              ),
              _InfoLine(
                icon: Icons.calendar_today_outlined,
                text: _formatDate(order.createdAt),
              ),
              _InfoLine(
                icon: Icons.store_mall_directory_outlined,
                text: _formatPickup(order.pickupDate, order.pickupTime),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${order.formattedTotal} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${order.itemsCount} article${order.itemsCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
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

String _formatPickup(String? pickupDate, String? pickupTime) {
  final date = pickupDate?.trim() ?? '';
  final time = pickupTime?.trim() ?? '';

  if (date.isEmpty && time.isEmpty) {
    return 'Retrait non précisé';
  }

  final shortTime = time.length >= 5 ? time.substring(0, 5) : time;
  if (date.isNotEmpty && shortTime.isNotEmpty) {
    return '$date à $shortTime';
  }
  return date.isNotEmpty ? date : shortTime;
}
