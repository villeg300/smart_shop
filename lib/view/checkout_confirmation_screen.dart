import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/order_controller.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/account_orders_screen.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  State<CheckoutConfirmationScreen> createState() =>
      _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState
    extends State<CheckoutConfirmationScreen> {
  final _notesController = TextEditingController();
  final _storeController = Get.find<StoreController>();
  late final OrderController _orderController;

  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;

  @override
  void initState() {
    super.initState();
    _orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1),
      initialDate: _pickupDate ?? DateTime(today.year, today.month, today.day),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _pickupDate = selected;
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _pickupTime = selected;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Choisir une date';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return 'Choisir une heure';
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _toApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _toApiTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _confirmCheckout() async {
    if (_pickupDate == null || _pickupTime == null) {
      Get.snackbar(
        'Information manquante',
        'Veuillez choisir la date et l\'heure de retrait.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await _orderController.placeOrder(
      pickupDate: _toApiDate(_pickupDate!),
      pickupTime: _toApiTime(_pickupTime!),
      shippingCost: 0,
      customerNotes: _notesController.text.trim(),
    );

    if (!success) {
      return;
    }

    if (!mounted) {
      return;
    }

    Get.off(() => const AccountOrdersScreen());
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation commande')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: SingleChildScrollView(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retrait en boutique',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    'Indiquez le jour et l\'heure de passage en boutique.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: spacing),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(_formatDate(_pickupDate)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time_outlined),
                          label: Text(_formatTime(_pickupTime)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Notes pour la commande (optionnel)',
                      hintText:
                          'Ex: Je passe vers 16h, merci de préparer la facture.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Obx(() {
                    final cart = _storeController.cart.value;
                    final total = _storeController.formattedCartTotal;
                    final itemsCount = cart?.itemsCount ?? 0;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Articles: $itemsCount'),
                          const SizedBox(height: 4),
                          Text(
                            'Total: $total FCFA',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: spacing),
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _orderController.isPlacingOrder.value
                            ? null
                            : _confirmCheckout,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _orderController.isPlacingOrder.value
                              ? 'Validation...'
                              : 'Confirmer la commande',
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
