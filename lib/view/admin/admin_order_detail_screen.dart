import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/constants/order_status_constants.dart';
import 'package:smart_shop/controllers/admin_order_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late final AdminOrderController _controller;
  late final TextEditingController _adminNotesController;

  OrderStatus? _selectedStatus;
  bool _loadingInitial = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminOrderController>()
        ? Get.find<AdminOrderController>()
        : Get.put(AdminOrderController());
    _adminNotesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  @override
  void dispose() {
    _adminNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder({bool showLoader = true}) async {
    final order = await _controller.loadOrderById(
      widget.orderId,
      showLoader: showLoader,
    );

    if (!mounted) return;

    if (order != null) {
      setState(() {
        _selectedStatus = order.status;
        _adminNotesController.text = order.adminNotes;
      });
    }

    if (_loadingInitial) {
      setState(() {
        _loadingInitial = false;
      });
    }
  }

  Future<void> _saveOrder(Order order) async {
    final editableStatuses = OrderStatusConstants.adminEditableStatuses(
      order.status,
    );
    final selectedStatus =
        _selectedStatus != null && editableStatuses.contains(_selectedStatus)
        ? _selectedStatus!
        : order.status;

    final ok = await _controller.updateStatus(
      orderId: order.id,
      status: OrderStatusConstants.backendValue(selectedStatus),
      adminNotes: _adminNotesController.text.trim(),
    );

    if (ok) {
      await _loadOrder(showLoader: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail commande admin'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => _loadOrder(),
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
            child: Obx(() {
              final selected = _controller.selectedOrder.value;
              final order = selected != null && selected.id == widget.orderId
                  ? selected
                  : null;

              if (order == null &&
                  (_loadingInitial || _controller.isLoading.value)) {
                return const Center(child: CircularProgressIndicator());
              }

              if (order == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 42),
                        const SizedBox(height: 10),
                        const Text('Commande introuvable'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadOrder,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final statusVisual = OrderStatusConstants.visual(
                context,
                order.status,
              );
              final editableStatuses =
                  OrderStatusConstants.adminEditableStatuses(order.status);
              final canEditStatus = OrderStatusConstants.canAdminEditStatus(
                order.status,
              );
              final selectedStatus =
                  _selectedStatus != null &&
                      editableStatuses.contains(_selectedStatus)
                  ? _selectedStatus!
                  : order.status;
              final hasStatusChanged = selectedStatus != order.status;
              final hasNotesChanged =
                  _adminNotesController.text.trim() != order.adminNotes.trim();
              final canSubmit =
                  !_controller.isUpdating.value &&
                  ((canEditStatus && hasStatusChanged) || hasNotesChanged);

              return RefreshIndicator(
                onRefresh: () => _loadOrder(showLoader: false),
                child: ListView(
                  padding: padding,
                  children: [
                    Card(
                      elevation: 2,
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
                                      AppTextStyles.bodyLarge,
                                      FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusVisual.background,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    OrderStatusConstants.label(order.status),
                                    style: TextStyle(
                                      color: statusVisual.foreground,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _DetailLine(
                              icon: Icons.calendar_month_outlined,
                              text: 'Créée le ${_formatDate(order.createdAt)}',
                            ),
                            _DetailLine(
                              icon: Icons.store_mall_directory_outlined,
                              text:
                                  'Retrait: ${_formatPickup(order.pickupDate, order.pickupTime)}',
                            ),
                            _DetailLine(
                              icon: Icons.account_balance_wallet_outlined,
                              text: '${order.formattedTotal} FCFA',
                              emphasize: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations client',
                              style: AppTextStyles.withWeight(
                                AppTextStyles.bodyLarge,
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _DetailLine(
                              icon: Icons.person_outline,
                              text:
                                  order.userFullName ?? 'Client non renseigné',
                            ),
                            _DetailLine(
                              icon: Icons.phone_outlined,
                              text:
                                  order.userPhoneNumber ??
                                  'Téléphone non renseigné',
                            ),
                            _DetailLine(
                              icon: Icons.email_outlined,
                              text: order.userEmail ?? 'Email non renseigné',
                            ),
                            if (order.customerNotes.trim().isNotEmpty)
                              _DetailLine(
                                icon: Icons.notes_outlined,
                                text:
                                    'Note client: ${order.customerNotes.trim()}',
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mise à jour du statut',
                              style: AppTextStyles.withWeight(
                                AppTextStyles.bodyLarge,
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (canEditStatus)
                              DropdownButtonFormField<OrderStatus>(
                                key: ValueKey(
                                  '${order.id}-${selectedStatus.name}',
                                ),
                                initialValue: selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Statut',
                                  prefixIcon: Icon(Icons.sync_alt_outlined),
                                ),
                                items: editableStatuses
                                    .map(
                                      (status) => DropdownMenuItem<OrderStatus>(
                                        value: status,
                                        child: Text(
                                          OrderStatusConstants.label(status),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                },
                              )
                            else
                              Text(
                                'Aucune transition de statut disponible.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _adminNotesController,
                              minLines: 2,
                              maxLines: 4,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Notes admin',
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: canSubmit
                                      ? () => _saveOrder(order)
                                      : null,
                                  icon: _controller.isUpdating.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: Text(
                                    _controller.isUpdating.value
                                        ? 'Mise à jour...'
                                        : 'Enregistrer',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      'Articles (${order.items.length})',
                      style: AppTextStyles.withWeight(
                        AppTextStyles.h3,
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => _OrderItemCard(item: item)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = item.variant?.imageUrl;
    final attributes = _attributesText(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
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
                        errorBuilder: (_, _, _) => Icon(
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (attributes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        attributes,
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
                      Text(
                        'Qté: ${item.quantity}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${item.formattedLineTotal} FCFA',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _attributesText(OrderItem item) {
    final variant = item.variant;
    if (variant == null) {
      return item.skuSnapshot.isNotEmpty ? 'SKU: ${item.skuSnapshot}' : '';
    }

    if (variant.attributesDisplay.trim().isNotEmpty) {
      return variant.attributesDisplay.trim();
    }

    if (variant.attributes.isNotEmpty) {
      return variant.attributes
          .map((attr) => '${attr.attributeName}: ${attr.value}')
          .join(' • ');
    }

    if (item.skuSnapshot.isNotEmpty) {
      return 'SKU: ${item.skuSnapshot}';
    }

    return '';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.text,
    this.emphasize = false,
  });

  final IconData icon;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final color = emphasize
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: emphasize ? 15 : 13.5,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
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
    return 'Non précisé';
  }

  final shortTime = time.length >= 5 ? time.substring(0, 5) : time;
  if (date.isNotEmpty && shortTime.isNotEmpty) {
    return '$date à $shortTime';
  }
  return date.isNotEmpty ? date : shortTime;
}
