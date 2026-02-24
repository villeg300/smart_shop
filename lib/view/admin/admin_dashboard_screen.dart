import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminOrderController>()
        ? Get.find<AdminOrderController>()
        : Get.put(AdminOrderController());
    _controller.loadOrders();
  }

  Future<void> _refresh() async {
    await _controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    final isMobile = AppResponsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            tooltip: 'Scanner une commande',
            onPressed: () => Get.to(() => const AdminScanOrderScreen()),
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => _controller.loadOrders(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: Obx(() {
                final orders = _controller.orders;
                final pendingCount = orders.where((o) => o.isPending).length;
                final inProgressCount = orders
                    .where(
                      (o) => o.isConfirmed || o.isProcessing || o.isShipped,
                    )
                    .length;
                final deliveredCount = orders
                    .where((o) => o.isDelivered)
                    .length;
                final cancelledCount = orders
                    .where((o) => o.isCancelled)
                    .length;
                final recent = orders.take(5).toList();

                return ListView(
                  padding: padding,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatusCountCard(
                          width: isMobile ? double.infinity : 220,
                          label: 'En attente',
                          count: pendingCount,
                          color: Colors.orange,
                          icon: Icons.schedule_outlined,
                        ),
                        _StatusCountCard(
                          width: isMobile ? double.infinity : 220,
                          label: 'En cours',
                          count: inProgressCount,
                          color: Colors.blue,
                          icon: Icons.local_shipping_outlined,
                        ),
                        _StatusCountCard(
                          width: isMobile ? double.infinity : 220,
                          label: 'Livrées',
                          count: deliveredCount,
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                        _StatusCountCard(
                          width: isMobile ? double.infinity : 220,
                          label: 'Annulées',
                          count: cancelledCount,
                          color: Colors.red,
                          icon: Icons.cancel_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ActionCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Toutes les commandes',
                          subtitle: 'Filtrer et gérer les statuts',
                          onTap: () => Get.to(() => const AdminOrdersScreen()),
                        ),
                        _ActionCard(
                          icon: Icons.qr_code_scanner_outlined,
                          title: 'Scanner un QR',
                          subtitle: 'Ouvrir une commande rapidement',
                          onTap: () =>
                              Get.to(() => const AdminScanOrderScreen()),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    Row(
                      children: [
                        Text(
                          'Dernières commandes',
                          style: AppTextStyles.withWeight(
                            AppTextStyles.h3,
                            FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              Get.to(() => const AdminOrdersScreen()),
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_controller.isLoading.value && orders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (recent.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Aucune commande trouvée'),
                      )
                    else
                      ...recent.map(
                        (order) => _MiniOrderTile(
                          order: order,
                          onTap: () => Get.to(
                            () => AdminOrderDetailScreen(orderId: order.id),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCountCard extends StatelessWidget {
  const _StatusCountCard({
    required this.width,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final double width;
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: AppTextStyles.withWeight(
                      AppTextStyles.h3,
                      FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppResponsive.isMobile(context) ? double.infinity : 280,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.withWeight(
                          AppTextStyles.bodyLarge,
                          FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniOrderTile extends StatelessWidget {
  const _MiniOrderTile({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusUi(context, order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          order.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.withWeight(
            AppTextStyles.bodyMedium,
            FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${order.userFullName ?? "Client"} • ${order.formattedTotal} FCFA',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: status.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.label,
            style: TextStyle(
              color: status.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusUi {
  const _StatusUi({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_StatusUi _statusUi(BuildContext context, OrderStatus status) {
  final scheme = Theme.of(context).colorScheme;

  switch (status) {
    case OrderStatus.pending:
      return _StatusUi(
        label: 'En attente',
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      );
    case OrderStatus.confirmed:
      return _StatusUi(
        label: 'Confirmée',
        background: Colors.green.withValues(alpha: 0.18),
        foreground: Colors.green.shade800,
      );
    case OrderStatus.processing:
      return _StatusUi(
        label: 'Traitement',
        background: Colors.blue.withValues(alpha: 0.16),
        foreground: Colors.blue.shade800,
      );
    case OrderStatus.shipped:
      return _StatusUi(
        label: 'Expédiée',
        background: Colors.indigo.withValues(alpha: 0.16),
        foreground: Colors.indigo.shade700,
      );
    case OrderStatus.delivered:
      return _StatusUi(
        label: 'Livrée',
        background: Colors.green.withValues(alpha: 0.2),
        foreground: Colors.green.shade900,
      );
    case OrderStatus.cancelled:
      return _StatusUi(
        label: 'Annulée',
        background: scheme.errorContainer.withValues(alpha: 0.75),
        foreground: scheme.onErrorContainer,
      );
  }
}
