import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/admin_order_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/admin/admin_order_detail_screen.dart';
import 'package:smart_shop/view/admin/admin_scan_order_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late final AdminOrderController _controller;
  late final TextEditingController _searchController;

  _OrderFilterOption _selectedFilter = _OrderFilterOption.all;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminOrderController>()
        ? Get.find<AdminOrderController>()
        : Get.put(AdminOrderController());
    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );

    if (_controller.selectedStatusFilter.value.isNotEmpty) {
      _selectedFilter = _OrderFilterOption.values.firstWhere(
        (filter) => filter.apiValue == _controller.selectedStatusFilter.value,
        orElse: () => _OrderFilterOption.all,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadOrders(
        status: _selectedFilter.apiValue,
        query: _searchController.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    await _controller.loadOrders(
      status: _selectedFilter.apiValue,
      query: _searchController.text.trim(),
    );
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedFilter = _OrderFilterOption.all;
      _searchController.clear();
    });
    await _controller.loadOrders(status: null, query: '');
  }

  Future<void> _quickUpdateStatus(Order order, String newStatus) async {
    final ok = await _controller.updateStatus(
      orderId: order.id,
      status: newStatus,
    );
    if (ok) {
      await _controller.loadOrders(
        status: _selectedFilter.apiValue,
        query: _searchController.text.trim(),
        showLoader: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des commandes'),
        actions: [
          IconButton(
            tooltip: 'Scanner une commande',
            onPressed: () => Get.to(() => const AdminScanOrderScreen()),
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _applyFilters,
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
            child: Padding(
              padding: padding,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            labelText:
                                'Rechercher (ID, client, email, téléphone)',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (_) => _applyFilters(),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<_OrderFilterOption>(
                          initialValue: _selectedFilter,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                            prefixIcon: Icon(Icons.filter_alt_outlined),
                          ),
                          items: _OrderFilterOption.values
                              .map(
                                (filter) =>
                                    DropdownMenuItem<_OrderFilterOption>(
                                      value: filter,
                                      child: Text(filter.label),
                                    ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedFilter = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _applyFilters,
                                icon: const Icon(Icons.search),
                                label: const Text('Appliquer'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Réinitialiser'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: Obx(() {
                      final orders = _controller.orders;

                      if (_controller.isLoading.value && orders.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (orders.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _applyFilters,
                          child: ListView(
                            children: const [
                              SizedBox(height: 120),
                              Icon(Icons.receipt_long, size: 66),
                              SizedBox(height: 12),
                              Center(
                                child: Text('Aucune commande pour ces filtres'),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _applyFilters,
                        child: ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _AdminOrderCard(
                              order: order,
                              onTap: () => Get.to(
                                () => AdminOrderDetailScreen(orderId: order.id),
                              ),
                              onQuickStatusChange: (status) =>
                                  _quickUpdateStatus(order, status),
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

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.order,
    required this.onTap,
    required this.onQuickStatusChange,
  });

  final Order order;
  final VoidCallback onTap;
  final ValueChanged<String> onQuickStatusChange;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(context, order.status);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                  _StatusBadge(style: statusStyle),
                  PopupMenuButton<String>(
                    tooltip: 'Changer le statut',
                    itemBuilder: (context) => _OrderFilterOption.values
                        .where((s) => s.apiValue.isNotEmpty)
                        .map(
                          (status) => PopupMenuItem<String>(
                            value: status.apiValue,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onSelected: onQuickStatusChange,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _InfoLine(
                icon: Icons.person_outline,
                text: order.userFullName ?? 'Client non renseigné',
              ),
              if ((order.userPhoneNumber ?? '').trim().isNotEmpty)
                _InfoLine(
                  icon: Icons.phone_outlined,
                  text: order.userPhoneNumber!.trim(),
                )
              else if ((order.userEmail ?? '').trim().isNotEmpty)
                _InfoLine(
                  icon: Icons.email_outlined,
                  text: order.userEmail!.trim(),
                ),
              _InfoLine(
                icon: Icons.calendar_month_outlined,
                text:
                    '${_formatDate(order.createdAt)} • ${_formatPickup(order.pickupDate, order.pickupTime)}',
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
                  OutlinedButton(
                    onPressed: onTap,
                    child: const Text('Détails'),
                  ),
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
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.style});

  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_StatusStyle _statusStyle(BuildContext context, OrderStatus status) {
  final scheme = Theme.of(context).colorScheme;

  switch (status) {
    case OrderStatus.pending:
      return _StatusStyle(
        label: 'En attente',
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      );
    case OrderStatus.confirmed:
      return _StatusStyle(
        label: 'Confirmée',
        background: Colors.green.withValues(alpha: 0.18),
        foreground: Colors.green.shade800,
      );
    case OrderStatus.processing:
      return _StatusStyle(
        label: 'Traitement',
        background: Colors.blue.withValues(alpha: 0.16),
        foreground: Colors.blue.shade700,
      );
    case OrderStatus.shipped:
      return _StatusStyle(
        label: 'Expédiée',
        background: Colors.indigo.withValues(alpha: 0.16),
        foreground: Colors.indigo.shade700,
      );
    case OrderStatus.delivered:
      return _StatusStyle(
        label: 'Livrée',
        background: Colors.green.withValues(alpha: 0.2),
        foreground: Colors.green.shade900,
      );
    case OrderStatus.cancelled:
      return _StatusStyle(
        label: 'Annulée',
        background: scheme.errorContainer.withValues(alpha: 0.75),
        foreground: scheme.onErrorContainer,
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

enum _OrderFilterOption {
  all(label: 'Tous les statuts', apiValue: ''),
  pending(label: 'En attente', apiValue: 'pending'),
  confirmed(label: 'Confirmée', apiValue: 'confirmed'),
  processing(label: 'En traitement', apiValue: 'processing'),
  shipped(label: 'Expédiée', apiValue: 'shipped'),
  delivered(label: 'Livrée', apiValue: 'delivered'),
  cancelled(label: 'Annulée', apiValue: 'cancelled');

  const _OrderFilterOption({required this.label, required this.apiValue});

  final String label;
  final String apiValue;
}
