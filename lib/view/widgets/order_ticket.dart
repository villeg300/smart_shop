import 'package:flutter/material.dart';
import 'package:smart_shop/models/order.dart';

class OrderTicket extends StatefulWidget {
  const OrderTicket({
    super.key,
    required this.order,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.borderRadius = 14,
  });

  final Order order;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  @override
  State<OrderTicket> createState() => _OrderTicketState();
}

class _OrderTicketState extends State<OrderTicket> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Card(
        margin: widget.margin,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              final sectionWidth = isCompact ? 60.0 : 68.0;
              final contentPadding = EdgeInsets.all(isCompact ? 12 : 14);
              final status = _statusStyle(context, widget.order);
              final textScale =
                  MediaQuery.of(context).textScaler.scale(14) / 14;
              final clampedScale = textScale.clamp(1.0, 1.25).toDouble();
              final baseHeight = isCompact ? 160.0 : 170.0;
              final ticketHeight = baseHeight * clampedScale;

              return SizedBox(
                height: ticketHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TicketBarcodeSection(
                      width: sectionWidth,
                      radius: widget.borderRadius,
                      data: widget.order.id,
                    ),
                    Expanded(
                      child: Padding(
                        padding: contentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Ticket de commande',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isCompact ? 16 : 17,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _OrderStatusBadge(style: status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _TicketInfoRow(
                              icon: Icons.calendar_month_outlined,
                              text: _formatShortDate(widget.order.createdAt),
                              compact: isCompact,
                            ),
                            _TicketInfoRow(
                              icon: Icons.list_alt_outlined,
                              text:
                                  '${widget.order.itemsCount} article${widget.order.itemsCount > 1 ? 's' : ''}',
                              compact: isCompact,
                            ),
                            _TicketInfoRow(
                              icon: Icons.account_balance_wallet_outlined,
                              text: '${widget.order.formattedTotal} FCFA',
                              compact: isCompact,
                              emphasize: true,
                            ),
                            _TicketInfoRow(
                              icon: Icons.store_mall_directory_outlined,
                              text: _pickupDateTime(widget.order),
                              compact: isCompact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  const _TicketInfoRow({
    required this.icon,
    required this.text,
    required this.compact,
    this.emphasize = false,
  });

  final IconData icon;
  final String text;
  final bool compact;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = emphasize
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.78);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: compact ? 16 : 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: emphasize ? (compact ? 15 : 16) : (compact ? 13 : 14),
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.style});

  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foreground),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketBarcodeSection extends StatelessWidget {
  const _TicketBarcodeSection({
    required this.width,
    required this.radius,
    required this.data,
  });

  final double width;
  final double radius;
  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(32, 108),
                painter: _BarcodePainter(data: data),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _PerforationDots(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerforationDots extends StatelessWidget {
  const _PerforationDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxHeight / 12).floor().clamp(8, 18);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Placeholder de type code-barres: stable par commande, sans dépendance externe.
class _BarcodePainter extends CustomPainter {
  _BarcodePainter({required this.data});

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    final bar = Paint()..color = Colors.black.withValues(alpha: 0.75);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      bg,
    );

    int seed = data.codeUnits.fold(0, (acc, c) => (acc * 33 + c) & 0x7fffffff);
    double y = 2;
    while (y < size.height - 2) {
      seed = (1103515245 * seed + 12345) & 0x7fffffff;
      final barHeight = (seed % 3) + 1;
      final gap = ((seed >> 4) % 3) + 1;
      canvas.drawRect(
        Rect.fromLTWH(2, y, size.width - 4, barHeight.toDouble()),
        bar,
      );
      y += barHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}

_StatusStyle _statusStyle(BuildContext context, Order order) {
  final scheme = Theme.of(context).colorScheme;

  if (order.isCancelled) {
    return _StatusStyle(
      label: 'Annulée',
      icon: Icons.cancel_outlined,
      background: scheme.errorContainer.withValues(alpha: 0.7),
      foreground: scheme.onErrorContainer,
    );
  }

  if (order.isProcessing) {
    return _StatusStyle(
      label: 'En traitement',
      icon: Icons.sync_outlined,
      background: Colors.green.withValues(alpha: 0.18),
      foreground: Colors.green.shade800,
    );
  }

  if (order.isPending) {
    return _StatusStyle(
      label: 'En attente',
      icon: Icons.schedule_outlined,
      background: scheme.surfaceContainerHighest,
      foreground: scheme.onSurfaceVariant,
    );
  }

  if (order.isReady) {
    return _StatusStyle(
      label: 'Prête',
      icon: Icons.local_shipping_outlined,
      background: Colors.green.withValues(alpha: 0.16),
      foreground: Colors.green.shade800,
    );
  }

  if (order.isPickedUp) {
    return _StatusStyle(
      label: 'Récupérée',
      icon: Icons.inventory_2_outlined,
      background: Colors.teal.withValues(alpha: 0.16),
      foreground: Colors.teal.shade800,
    );
  }

  return _StatusStyle(
    label: order.statusDisplay,
    icon: Icons.receipt_long_outlined,
    background: scheme.primaryContainer.withValues(alpha: 0.65),
    foreground: scheme.onPrimaryContainer,
  );
}

String _formatShortDate(DateTime date) {
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

String _pickupDateTime(Order order) {
  String two(int value) => value.toString().padLeft(2, '0');

  final pickupDate = order.pickupDate?.trim() ?? '';
  final pickupTime = order.pickupTime?.trim() ?? '';
  if (pickupDate.isNotEmpty || pickupTime.isNotEmpty) {
    final normalizedTime = pickupTime.length >= 5
        ? pickupTime.substring(0, 5)
        : pickupTime;
    if (pickupDate.isNotEmpty && normalizedTime.isNotEmpty) {
      return '$pickupDate a $normalizedTime';
    }
    return pickupDate.isNotEmpty ? pickupDate : normalizedTime;
  }

  final created = order.createdAt;
  return '${created.year}-${two(created.month)}-${two(created.day)} a ${two(created.hour)}:${two(created.minute)}';
}
