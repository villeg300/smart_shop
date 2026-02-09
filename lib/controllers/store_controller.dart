import 'package:get/get.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/variant.dart';
import '../models/cart.dart';
import '../services/catalog_service.dart';
import '../services/cart_service.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

class StoreController extends GetxController {
  // Services
  late final CatalogService _catalogService;
  late final CartService _cartService;
  late final AuthController _authController;

  // État
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Variant> variants = <Variant>[].obs;
  final Rx<Cart?> cart = Rx<Cart?>(null);

  final RxString selectedCategorySlug = 'toutes'.obs;
  final RxSet<String> favoriteProductIds = <String>{}.obs;

  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingCart = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialiser les services
    final apiClient = ApiClient(baseUrl: 'http://192.168.11.173:8000');
    _catalogService = CatalogService(apiClient);
    _cartService = CartService(apiClient);
    _authController = Get.find<AuthController>();

    ever(_authController.currentUserRx, (user) {
      if (user == null) {
        _setCart(null);
        return;
      }
      loadCart();
    });

    // Charger les données initiales
    loadCategories();
    loadProducts();
    if (_authController.currentUser != null) {
      loadCart();
    }
  }

  void _setCart(Cart? newCart) {
    cart.value = newCart;
    cart.refresh();
  }

  // =========================
  // CATÉGORIES
  // =========================

  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;

      final fetchedCategories = await _catalogService.fetchCategories();

      // Ajouter la catégorie "Toutes" au début
      categories.value = [
        Category(
          name: 'Toutes',
          slug: 'toutes',
          isActive: true,
          createdAt: DateTime.now(),
          productCount: 0,
        ),
        ...fetchedCategories,
      ];
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les catégories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  List<String> get categoryLabels => categories.map((c) => c.name).toList();

  int indexBySlug(String slug) {
    final index = categories.indexWhere((c) => c.slug == slug);
    return index == -1 ? 0 : index;
  }

  String slugByIndex(int index) {
    if (index < 0 || index >= categories.length) {
      return 'toutes';
    }
    return categories[index].slug;
  }

  void setCategory(String slug) {
    selectedCategorySlug.value = slug;
    currentPage.value = 1;
    products.clear();
    loadProducts();
  }

  // =========================
  // PRODUITS
  // =========================

  Future<void> loadProducts({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoadingProducts.value = true;
      }

      final result = await _catalogService.fetchProducts(
        categorySlug: selectedCategorySlug.value,
        page: currentPage.value,
      );

      final fetchedProducts = result['products'] as List<Product>;

      if (loadMore) {
        products.addAll(fetchedProducts);
      } else {
        products.value = fetchedProducts;
      }

      totalProducts.value = result['count'] as int;
      hasMore.value = result['next'] != null;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMore.value || isLoadingProducts.value) return;

    currentPage.value++;
    await loadProducts(loadMore: true);
  }

  List<Product> get filteredProducts => products;

  // =========================
  // VARIANTES
  // =========================

  Future<List<Variant>> loadVariantsForProduct(String productId) async {
    try {
      final result = await _catalogService.fetchVariants(productId: productId);
      return result['variants'] as List<Variant>;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les variantes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // =========================
  // PANIER
  // =========================

  Future<void> loadCart({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoadingCart.value = true;
      }
      final user = _authController.currentUser;
      if (user == null) {
        _setCart(null);
        return;
      }
      final fetchedCart = await _cartService.getOrCreateCart(userId: user.id);
      _setCart(fetchedCart);
    } catch (e) {
      print(e);
    } finally {
      if (showLoader) {
        isLoadingCart.value = false;
      }
    }
  }

  Future<void> addToCart(Variant variant, {int quantity = 1}) async {
    try {
      if (cart.value == null) {
        await loadCart();
      }

      if (cart.value == null) {
        throw Exception('Impossible de créer le panier');
      }

      // Vérifier si l'article existe déjà
      final existingItem = cart.value!.items.firstWhereOrNull(
        (item) => item.variant.id == variant.id,
      );

      if (existingItem != null) {
        // Mettre à jour la quantité
        await _cartService.updateCartItem(
          itemId: existingItem.id,
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Ajouter nouvel article
        await _cartService.addToCart(
          cartId: cart.value!.id,
          variantId: variant.id,
          quantity: quantity,
          unitPrice: variant.finalPrice,
        );
      }

      // Recharger le panier en arrière-plan
      await loadCart(showLoader: false);

      Get.snackbar(
        'Succès',
        'Article ajouté au panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    try {
      final previousCart = cart.value;
      if (previousCart != null) {
        final updatedItems = List<CartItem>.from(previousCart.items)
          ..removeWhere((cartItem) => cartItem.id == item.id);
        _setCart(previousCart.copyWith(items: updatedItems));
      }

      await _cartService.removeFromCart(item.id);

      Get.snackbar(
        'Succès',
        'Article retiré du panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      await loadCart(showLoader: false);
      Get.snackbar(
        'Erreur',
        'Impossible de retirer l\'article: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    try {
      if (quantity == item.quantity) return;
      final previousCart = cart.value;

      if (previousCart != null) {
        final updatedItems = List<CartItem>.from(previousCart.items);
        final index =
            updatedItems.indexWhere((cartItem) => cartItem.id == item.id);
        if (index != -1) {
          if (quantity <= 0) {
            updatedItems.removeAt(index);
          } else {
            updatedItems[index] =
                updatedItems[index].copyWith(quantity: quantity);
          }
          _setCart(previousCart.copyWith(items: updatedItems));
        }
      }

      if (quantity <= 0) {
        await _cartService.removeFromCart(item.id);
        return;
      }

      await _cartService.updateCartItem(itemId: item.id, quantity: quantity);
    } catch (e) {
      await loadCart(showLoader: false);
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la quantité: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearCart() async {
    try {
      if (cart.value == null) return;

      final previousCart = cart.value;
      _setCart(previousCart?.copyWith(items: []));

      await _cartService.clearCart(previousCart!.id);

      Get.snackbar(
        'Succès',
        'Panier vidé',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      await loadCart(showLoader: false);
      Get.snackbar(
        'Erreur',
        'Impossible de vider le panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // FAVORIS
  // =========================

  bool isFavorite(Product product) {
    return favoriteProductIds.contains(product.id);
  }

  void toggleFavorite(Product product) {
    if (favoriteProductIds.contains(product.id)) {
      favoriteProductIds.remove(product.id);
    } else {
      favoriteProductIds.add(product.id);
    }
  }

  // =========================
  // GETTERS
  // =========================

  int get cartItemsCount => cart.value?.itemsCount ?? 0;

  double get cartTotal => cart.value?.calculatedTotal ?? 0.0;

  String get formattedCartTotal => cart.value?.formattedTotal ?? '0';

  bool get hasItemsInCart => cart.value?.isNotEmpty ?? false;
}
