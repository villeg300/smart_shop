import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/constants/order_status_constants.dart';
import 'package:smart_shop/controllers/admin_order_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/admin/admin_order_detail_screen.dart';
import 'package:smart_shop/view/admin/admin_orders_screen.dart';
import 'package:smart_shop/view/admin/admin_scan_order_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminOrderController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminOrderController>()
        ? Get.find<AdminOrderController>()
        : Get.put(AdminOrderController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadOrders();
    });
  }

  Future<void> _refreshCurrentTab() async {
    if (_selectedIndex == 1) {
      final status = _controller.selectedStatusFilter.value;
      await _controller.loadOrders(
        status: status.isEmpty
            ? OrderStatusConstants.backendValue(OrderStatus.pending)
            : status,
        query: _controller.searchQuery.value,
      );
      return;
    }
    await _controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Stats', 'Commandes', 'Produits', 'Utilisateurs'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refreshCurrentTab,
            icon: const Icon(Icons.refresh),
          ),
          if (_selectedIndex == 1)
            IconButton(
              tooltip: 'Scanner',
              onPressed: () => Get.to(
                () => const AdminScanOrderScreen(mode: AdminScanMode.find),
              ),
              icon: const Icon(Icons.qr_code_scanner_outlined),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _AdminStatsTab(),
          AdminOrdersTab(),
          _AdminPlaceholderTab(
            title: 'Produits',
            subtitle: 'Gestion catalogue à venir',
            icon: Icons.inventory_2_outlined,
          ),
          _AdminPlaceholderTab(
            title: 'Utilisateurs',
            subtitle: 'Gestion clients et staff à venir',
            icon: Icons.group_outlined,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produits',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
        ],
      ),
    );
  }
}

class _AdminStatsTab extends StatelessWidget {
  const _AdminStatsTab();

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppResponsive.contentMaxWidth(context),
          ),
          child: Obx(() {
            final controller = Get.find<AdminOrderController>();
            final recentOrders = controller.orders.take(4).toList();

            return RefreshIndicator(
              onRefresh: controller.loadOrders,
              child: ListView(
                padding: padding,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12) / 2;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: OrderStatusConstants.statsStatuses.map((
                          status,
                        ) {
                          final visual = OrderStatusConstants.visual(
                            context,
                            status,
                          );
                          final count = controller.countByStatus(status);

                          return SizedBox(
                            width: cardWidth,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: visual.background,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    OrderStatusConstants.icon(status),
                                    color: visual.foreground,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$count',
                                    style: AppTextStyles.withWeight(
                                      AppTextStyles.h2,
                                      FontWeight.w700,
                                    ).copyWith(color: visual.foreground),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    OrderStatusConstants.label(status),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: visual.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        'Actions rapides',
                        style: AppTextStyles.withWeight(
                          AppTextStyles.h3,
                          FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.to(
                            () => const AdminScanOrderScreen(
                              mode: AdminScanMode.find,
                              title: 'Chercher une commande',
                            ),
                          ),
                          icon: const Icon(Icons.qr_code_scanner_outlined),
                          label: const Text('Chercher'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.to(
                            () => const AdminScanOrderScreen(
                              mode: AdminScanMode.confirm,
                              title: 'Confirmer une commande',
                            ),
                          ),
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        'Commandes récentes',
                        style: AppTextStyles.withWeight(
                          AppTextStyles.h3,
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (controller.isLoading.value && recentOrders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (recentOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Aucune commande disponible.'),
                    )
                  else
                    ...recentOrders.map(
                      (order) => _RecentOrderTile(order: order),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final visual = OrderStatusConstants.visual(context, order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onTap: () => Get.to(() => AdminOrderDetailScreen(orderId: order.id)),
        title: Text(
          order.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.withWeight(
            AppTextStyles.bodyMedium,
            FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${order.userFullName ?? "Client"} • ${order.formattedTotal} FCFA',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: visual.background,
            borderRadius: BorderRadius.circular(18),
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
      ),
    );
  }
}

class _AdminPlaceholderTab extends StatelessWidget {
  const _AdminPlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppResponsive.contentMaxWidth(context),
          ),
          child: Padding(
            padding: AppResponsive.pagePadding(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: AppTextStyles.withWeight(
                      AppTextStyles.h3,
                      FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
