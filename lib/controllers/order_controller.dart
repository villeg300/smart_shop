import 'package:get/get.dart';
import 'package:smart_shop/config/app_config.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/order.dart';
import 'package:smart_shop/services/api_client.dart';
import 'package:smart_shop/services/app_feedback_service.dart';
import 'package:smart_shop/services/order_service.dart';

class OrderController extends GetxController {
  late final OrderService _orderService;
  late final AuthController _authController;
  bool _bootstrapped = false;

  final RxList<Order> orders = <Order>[].obs;
  final Rx<Order?> currentOrder = Rx<Order?>(null);

  final RxBool isLoadingOrders = false.obs;
  final RxBool isPlacingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();

    final apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
    _orderService = OrderService(apiClient);
    _authController = Get.find<AuthController>();

    ever(_authController.currentUserRx, (user) {
      if (user == null) {
        clearData();
        return;
      }
      ensureBootstrapped(force: true);
    });

    if (_authController.currentUser != null) {
      ensureBootstrapped();
    }
  }

  Future<void> ensureBootstrapped({bool force = false}) async {
    if (_bootstrapped && !force) {
      return;
    }
    if (!_isAuthenticated()) {
      clearData();
      return;
    }
    _bootstrapped = true;
    await loadOrders();
  }

  void clearData() {
    orders.clear();
    currentOrder.value = null;
    isLoadingOrders.value = false;
    isPlacingOrder.value = false;
    _bootstrapped = false;
  }

  bool _isAuthenticated({bool notify = false}) {
    final isAuthed = _authController.currentUser != null;
    if (!isAuthed && notify) {
      AppFeedbackService.showError(
        title: 'Connexion requise',
        message: 'Connectez-vous pour accéder à vos commandes.',
      );
    }
    return isAuthed;
  }

  // =========================
  // CHARGER LES COMMANDES
  // =========================

  Future<void> loadOrders() async {
    if (!_isAuthenticated()) {
      clearData();
      return;
    }

    try {
      isLoadingOrders.value = true;

      final fetchedOrders = await _orderService.fetchOrders();
      orders.value = fetchedOrders;
    } catch (e) {
      AppFeedbackService.showError(
        title: 'Erreur',
        error: e,
        fallbackMessage: 'Impossible de charger les commandes.',
      );
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> loadOrderById(String orderId) async {
    if (!_isAuthenticated()) {
      clearData();
      return;
    }

    try {
      final order = await _orderService.fetchOrderById(orderId);
      currentOrder.value = order;
    } catch (e) {
      AppFeedbackService.showError(
        title: 'Erreur',
        error: e,
        fallbackMessage: 'Impossible de charger la commande.',
      );
    }
  }

  // =========================
  // PASSER UNE COMMANDE
  // =========================

  Future<bool> placeOrder({
    required String pickupDate,
    required String pickupTime,
    double shippingCost = 0,
    String customerNotes = '',
  }) async {
    if (!_isAuthenticated(notify: true)) {
      return false;
    }

    try {
      isPlacingOrder.value = true;

      final storeController = Get.find<StoreController>();
      final cart = storeController.cart.value;

      if (cart == null || cart.isEmpty) {
        AppFeedbackService.showError(
          title: 'Panier vide',
          message: 'Votre panier est vide.',
        );
        return false;
      }

      final order = await _orderService.checkout(
        cartId: cart.id,
        pickupDate: pickupDate,
        pickupTime: pickupTime,
        shippingCost: shippingCost,
        customerNotes: customerNotes,
      );

      currentOrder.value = order;
      orders.insert(0, order);

      await storeController.loadCart(showLoader: false);

      AppFeedbackService.showSuccess(
        title: 'Commande confirmée !',
        message: 'Votre commande a bien été enregistrée.',
        mode: FeedbackDisplayMode.popup,
        actionLabel: 'Voir mes commandes',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(
        title: 'Erreur',
        error: e,
        fallbackMessage: 'Impossible de passer la commande.',
        mode: FeedbackDisplayMode.popup,
        actionLabel: 'Fermer',
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
    if (!_isAuthenticated(notify: true)) {
      return false;
    }

    try {
      final order = await _orderService.cancelOrder(orderId, reason: reason);

      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = order;
      }

      if (currentOrder.value?.id == orderId) {
        currentOrder.value = order;
      }

      AppFeedbackService.showSuccess(
        title: 'Succès',
        message: 'Commande annulée.',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(
        title: 'Erreur',
        error: e,
        fallbackMessage: 'Impossible d\'annuler la commande.',
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
  List<Order> get processingOrders => getOrdersByStatus(OrderStatus.processing);
  List<Order> get readyOrders => getOrdersByStatus(OrderStatus.ready);
  List<Order> get pickedUpOrders => getOrdersByStatus(OrderStatus.pickedUp);
  List<Order> get cancelledOrders => getOrdersByStatus(OrderStatus.cancelled);

  List<Order> get activeOrders {
    return orders
        .where((order) => !order.isPickedUp && !order.isCancelled)
        .toList();
  }

  List<Order> get orderHistory {
    return orders
        .where((order) => order.isPickedUp || order.isCancelled)
        .toList();
  }

  // =========================
  // STATISTIQUES
  // =========================

  int get totalOrders => orders.length;

  int get activeOrdersCount => activeOrders.length;

  double get totalSpent {
    return pickedUpOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
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
