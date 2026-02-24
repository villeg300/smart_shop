import 'package:get/get.dart';
import 'package:smart_shop/config/app_config.dart';
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

  Future<void> loadOrders({
    String? status,
    String? query,
    bool showLoader = true,
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

      orders.value = fetched;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les commandes admin: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Order?> loadOrderById(String orderId, {bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      final order = await _service.fetchOrderById(orderId);
      selectedOrder.value = order;
      return order;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Commande introuvable ou inaccessible: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStatus({
    required String orderId,
    required String status,
    String? adminNotes,
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

      Get.snackbar(
        'Succès',
        'Statut de commande mis à jour',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
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
