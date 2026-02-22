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

  String? _formatPickup(Order order) {
    final date = order.pickupDate?.trim();
    final time = order.pickupTime?.trim();
    if ((date == null || date.isEmpty) && (time == null || time.isEmpty)) {
      return null;
    }
    if (date != null && date.isNotEmpty && time != null && time.isNotEmpty) {
      return '$date a $time';
    }
    return (date != null && date.isNotEmpty) ? date : time;
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

  _OrderStatusMeta _statusMeta(Order order) {
    if (order.isDelivered) {
      return const _OrderStatusMeta(label: 'LIVREE', icon: Icons.check_circle);
    }
    if (order.isCancelled) {
      return const _OrderStatusMeta(label: 'ANNULEE', icon: Icons.cancel);
    }
    if (order.isShipped) {
      return const _OrderStatusMeta(
        label: 'EXPEDIEE',
        icon: Icons.local_shipping,
      );
    }
    if (order.isProcessing) {
      return const _OrderStatusMeta(label: 'TRAITEMENT', icon: Icons.sync);
    }
    if (order.isConfirmed) {
      return const _OrderStatusMeta(label: 'CONFIRMEE', icon: Icons.verified);
    }
    return const _OrderStatusMeta(
      label: 'EN ATTENTE',
      icon: Icons.hourglass_top,
    );
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
                  'Detail commande',
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
                            final statusMeta = _statusMeta(order);
                            final pickup = _formatPickup(order);
                            final canCancel = order.canBeCancelled;
                            final ticketBorderColor = Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.38);

                            return InkWell(
                              onTap: () => _showOrderDetails(order),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ticketBorderColor,
                                    width: 1.1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final isCompact = width < 370;
                                      final qrSectionWidth = isCompact
                                          ? 96.0
                                          : 118.0;
                                      final statusSectionWidth = isCompact
                                          ? 50.0
                                          : 60.0;
                                      final ticketHeight = canCancel
                                          ? (isCompact ? 198.0 : 186.0)
                                          : (isCompact ? 174.0 : 162.0);
                                      final qrSize = isCompact ? 58.0 : 72.0;
                                      final insidePadding = isCompact
                                          ? const EdgeInsets.fromLTRB(
                                              10,
                                              10,
                                              8,
                                              8,
                                            )
                                          : const EdgeInsets.fromLTRB(
                                              12,
                                              12,
                                              10,
                                              10,
                                            );

                                      return SizedBox(
                                        height: ticketHeight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(
                                              width: qrSectionWidth,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 12,
                                                    ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    _TicketQrCode(
                                                      data: order.id,
                                                      size: qrSize,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            _TicketPerforationLine(
                                              color: ticketBorderColor,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: insidePadding,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Ticket commande',
                                                      style: TextStyle(
                                                        fontSize: isCompact
                                                            ? 11
                                                            : 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _TicketInfoLine(
                                                      icon:
                                                          Icons.event_outlined,
                                                      label: _formatDate(
                                                        order.createdAt,
                                                      ),
                                                      compact: isCompact,
                                                    ),
                                                    _TicketInfoLine(
                                                      icon: Icons
                                                          .list_alt_outlined,
                                                      label:
                                                          '${order.itemsCount} article${order.itemsCount > 1 ? 's' : ''}',
                                                      compact: isCompact,
                                                    ),
                                                    _TicketInfoLine(
                                                      icon: Icons
                                                          .payments_outlined,
                                                      label:
                                                          '${order.formattedTotal} FCFA',
                                                      emphasize: true,
                                                      compact: isCompact,
                                                    ),
                                                    if (pickup != null &&
                                                        pickup.isNotEmpty)
                                                      _TicketInfoLine(
                                                        icon: Icons
                                                            .storefront_outlined,
                                                        label: pickup,
                                                        compact: isCompact,
                                                      ),
                                                    if (order.customerNotes
                                                        .trim()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          order.customerNotes
                                                              .trim(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: isCompact
                                                                ? 10
                                                                : 11,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.color
                                                                    ?.withValues(
                                                                      alpha:
                                                                          0.7,
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                    const Spacer(),
                                                    if (canCancel)
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: OutlinedButton.icon(
                                                          onPressed: () =>
                                                              _confirmCancel(
                                                                order,
                                                              ),
                                                          icon: Icon(
                                                            Icons
                                                                .cancel_outlined,
                                                            size: isCompact
                                                                ? 16
                                                                : 18,
                                                          ),
                                                          label: Text(
                                                            'Annuler la commande',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isCompact
                                                                  ? 12
                                                                  : 13,
                                                            ),
                                                          ),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                            side: BorderSide(
                                                              color: Colors.red
                                                                  .withValues(
                                                                    alpha: 0.4,
                                                                  ),
                                                            ),
                                                            backgroundColor:
                                                                Colors.red
                                                                    .withValues(
                                                                      alpha:
                                                                          0.05,
                                                                    ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical:
                                                                      isCompact
                                                                      ? 8
                                                                      : 10,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor
                                                                  .withValues(
                                                                    alpha: 0.08,
                                                                  ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          'Statut final, annulation indisponible',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: isCompact
                                                                ? 11
                                                                : 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            _TicketPerforationLine(
                                              color: ticketBorderColor,
                                            ),
                                            _TicketStatusRail(
                                              status: statusMeta.label,
                                              icon: statusMeta.icon,
                                              color: statusColor,
                                              width: statusSectionWidth,
                                              compact: isCompact,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
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

class _TicketInfoLine extends StatelessWidget {
  const _TicketInfoLine({
    required this.icon,
    required this.label,
    this.emphasize = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textColor = emphasize
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: compact ? 14 : 16,
            color: textColor?.withValues(alpha: emphasize ? 1 : 0.7),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11.5 : 12.5,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketPerforationLine extends StatelessWidget {
  const _TicketPerforationLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final cutColor = Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      width: 18,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cutColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = (constraints.maxHeight / 8).floor().clamp(8, 48);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count,
                    (_) => Container(
                      width: 2,
                      height: 4,
                      color: color.withValues(alpha: 0.85),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cutColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketStatusRail extends StatelessWidget {
  const _TicketStatusRail({
    required this.status,
    required this.icon,
    required this.color,
    required this.width,
    required this.compact,
  });

  final String status;
  final IconData icon;
  final Color color;
  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.12),
          ],
        ),
        border: Border(left: BorderSide(color: color.withValues(alpha: 0.25))),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: compact ? 30 : 34,
            height: compact ? 30 : 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Icon(icon, size: compact ? 15 : 17, color: color),
          ),
          SizedBox(height: compact ? 8 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 3 : 4,
              vertical: compact ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: compact ? 9.5 : 10.5,
                  letterSpacing: compact ? 0.5 : 0.9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusMeta {
  const _OrderStatusMeta({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _TicketQrCode extends StatelessWidget {
  const _TicketQrCode({required this.data, this.size = 72});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(painter: _PseudoQrPainter(data)),
    );
  }
}

class _PseudoQrPainter extends CustomPainter {
  _PseudoQrPainter(this.data);

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    const modules = 21;
    final cell = size.width / modules;
    final black = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;

    canvas.drawRect(Offset.zero & size, white);

    int seed = data.codeUnits.fold(
      0,
      (acc, char) => (acc * 31 + char) & 0x7fffffff,
    );

    bool nextBit() {
      seed = (1103515245 * seed + 12345) & 0x7fffffff;
      return (seed & 1) == 1;
    }

    for (int y = 0; y < modules; y++) {
      for (int x = 0; x < modules; x++) {
        if (_isInFinderZone(x, y)) {
          continue;
        }
        if (nextBit()) {
          final rect = Rect.fromLTWH(x * cell, y * cell, cell, cell);
          canvas.drawRect(rect, black);
        }
      }
    }

    _drawFinder(canvas, 0, 0, cell, black, white);
    _drawFinder(canvas, 14, 0, cell, black, white);
    _drawFinder(canvas, 0, 14, cell, black, white);
  }

  bool _isInFinderZone(int x, int y) {
    final topLeft = x <= 7 && y <= 7;
    final topRight = x >= 13 && y <= 7;
    final bottomLeft = x <= 7 && y >= 13;
    return topLeft || topRight || bottomLeft;
  }

  void _drawFinder(
    Canvas canvas,
    int startX,
    int startY,
    double cell,
    Paint black,
    Paint white,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(startX * cell, startY * cell, 7 * cell, 7 * cell),
      black,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (startX + 1) * cell,
        (startY + 1) * cell,
        5 * cell,
        5 * cell,
      ),
      white,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (startX + 2) * cell,
        (startY + 2) * cell,
        3 * cell,
        3 * cell,
      ),
      black,
    );
  }

  @override
  bool shouldRepaint(covariant _PseudoQrPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
