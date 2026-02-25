import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:smart_shop/config/app_config.dart';
import 'package:smart_shop/constants/order_status_constants.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/services/admin_order_service.dart';
import 'package:smart_shop/services/api_client.dart';

class AdminOrderController extends GetxController {
  late final AdminOrderService _service;

  final RxList<Order> orders = <Order>[].obs;
  final Rx<Order?> selectedOrder = Rx<Order?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  final RxString selectedStatusFilter = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = AdminOrderService(ApiClient(baseUrl: AppConfig.baseUrl));
  }

  void _showSnackbarSafely(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;
      Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
    });
  }

  int countByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).length;
  }

  Future<void> loadOrders({
    String? status,
    String? query,
    bool showLoader = true,
    bool notifyOnError = true,
  }) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      selectedStatusFilter.value = status ?? selectedStatusFilter.value;
      searchQuery.value = query ?? searchQuery.value;

      final fetched = await _service.fetchOrders(
        status: selectedStatusFilter.value.isEmpty
            ? null
            : selectedStatusFilter.value,
        query: searchQuery.value,
      );

      orders.assignAll(fetched);
    } catch (e) {
      if (notifyOnError) {
        _showSnackbarSafely(
          'Erreur',
          'Impossible de charger les commandes admin: $e',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<Order?> loadOrderById(
    String orderId, {
    bool showLoader = true,
    bool notifyOnError = true,
  }) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      final order = await _service.fetchOrderById(orderId);
      selectedOrder.value = order;
      return order;
    } catch (e) {
      if (notifyOnError) {
        _showSnackbarSafely(
          'Erreur',
          'Commande introuvable ou inaccessible: $e',
        );
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStatus({
    required String orderId,
    required String status,
    String? adminNotes,
    bool notifyOnError = true,
    bool notifyOnSuccess = true,
  }) async {
    try {
      isUpdating.value = true;
      final updated = await _service.updateOrderStatus(
        orderId: orderId,
        status: status,
        adminNotes: adminNotes,
      );

      selectedOrder.value = updated;
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        orders[index] = updated;
      }

      if (notifyOnSuccess) {
        _showSnackbarSafely('Succès', 'Statut de commande mis à jour');
      }
      return true;
    } catch (e) {
      if (notifyOnError) {
        _showSnackbarSafely(
          'Erreur',
          'Impossible de mettre à jour le statut: $e',
        );
      }
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<bool> markOrderPickedUpById(String orderId) async {
    final order = await loadOrderById(
      orderId,
      showLoader: false,
      notifyOnError: false,
    );

    if (order == null) {
      _showSnackbarSafely('Introuvable', 'Commande non trouvée: $orderId');
      return false;
    }

    if (order.status != OrderStatus.ready) {
      _showSnackbarSafely(
        'Info',
        'La commande doit être prête avant de la marquer récupérée.',
      );
      return false;
    }

    return updateStatus(
      orderId: orderId,
      status: OrderStatusConstants.backendValue(OrderStatus.pickedUp),
      notifyOnSuccess: true,
    );
  }

  Future<bool> confirmOrderById(String orderId) {
    return markOrderPickedUpById(orderId);
  }

  static String? extractOrderIdFromScan(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return null;

    final regex = RegExp(r'SS-ODR-[A-Za-z0-9]+');
    final match = regex.firstMatch(trimmed);
    if (match != null) {
      return match.group(0);
    }

    if (trimmed.startsWith('SS-ODR-')) {
      return trimmed;
    }

    return null;
  }
}
