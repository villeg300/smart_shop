import 'package:get/get.dart';
import '../models/order.dart';
import '../config/app_config.dart';
import '../services/order_service.dart';
import '../services/api_client.dart';
import 'store_controller.dart';

class OrderController extends GetxController {
  late final OrderService _orderService;

  final RxList<Order> orders = <Order>[].obs;
  final Rx<Order?> currentOrder = Rx<Order?>(null);

  final RxBool isLoadingOrders = false.obs;
  final RxBool isPlacingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialiser le service
    final apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
    _orderService = OrderService(apiClient);

    // Charger les commandes
    loadOrders();
  }

  // =========================
  // CHARGER LES COMMANDES
  // =========================

  Future<void> loadOrders() async {
    try {
      isLoadingOrders.value = true;

      final fetchedOrders = await _orderService.fetchOrders();
      orders.value = fetchedOrders;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les commandes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> loadOrderById(String orderId) async {
    try {
      final order = await _orderService.fetchOrderById(orderId);
      currentOrder.value = order;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger la commande: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // PASSER UNE COMMANDE
  // =========================

  Future<bool> placeOrder({
    double shippingCost = 0,
    String customerNotes = '',
  }) async {
    try {
      isPlacingOrder.value = true;

      // Récupérer le panier depuis StoreController
      final storeController = Get.find<StoreController>();
      final cart = storeController.cart.value;

      if (cart == null || cart.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Votre panier est vide',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Passer la commande
      final order = await _orderService.checkout(
        cartId: cart.id,
        shippingCost: shippingCost,
        customerNotes: customerNotes,
      );

      // Sauvegarder la commande
      currentOrder.value = order;
      orders.insert(0, order);

      // Recharger le panier (qui devrait être vide maintenant)
      await storeController.loadCart();

      Get.snackbar(
        'Succès',
        'Commande passée avec succès!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de passer la commande: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  // =========================
  // ANNULER UNE COMMANDE
  // =========================

  Future<bool> cancelOrder(String orderId, {String reason = ''}) async {
    try {
      final order = await _orderService.cancelOrder(orderId, reason: reason);

      // Mettre à jour dans la liste
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = order;
      }

      // Mettre à jour la commande courante si c'est la même
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = order;
      }

      Get.snackbar(
        'Succès',
        'Commande annulée',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler la commande: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // =========================
  // FILTRES ET TRIS
  // =========================

  List<Order> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  List<Order> get pendingOrders => getOrdersByStatus(OrderStatus.pending);
  List<Order> get confirmedOrders => getOrdersByStatus(OrderStatus.confirmed);
  List<Order> get processingOrders => getOrdersByStatus(OrderStatus.processing);
  List<Order> get shippedOrders => getOrdersByStatus(OrderStatus.shipped);
  List<Order> get deliveredOrders => getOrdersByStatus(OrderStatus.delivered);
  List<Order> get cancelledOrders => getOrdersByStatus(OrderStatus.cancelled);

  List<Order> get activeOrders {
    return orders
        .where((order) => !order.isDelivered && !order.isCancelled)
        .toList();
  }

  List<Order> get orderHistory {
    return orders
        .where((order) => order.isDelivered || order.isCancelled)
        .toList();
  }

  // =========================
  // STATISTIQUES
  // =========================

  int get totalOrders => orders.length;

  int get activeOrdersCount => activeOrders.length;

  double get totalSpent {
    return deliveredOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  String get formattedTotalSpent {
    final total = totalSpent.toStringAsFixed(0);
    return total.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  Order? get lastOrder => orders.isNotEmpty ? orders.first : null;
}
