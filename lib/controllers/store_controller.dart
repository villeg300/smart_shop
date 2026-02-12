import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:smart_shop/config/app_config.dart';
import 'package:smart_shop/models/cart.dart';
import 'package:smart_shop/models/category.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/variant.dart';
import 'package:smart_shop/services/api_client.dart';
import 'package:smart_shop/services/cart_service.dart';
import 'package:smart_shop/services/catalog_service.dart';

import 'auth_controller.dart';

class StoreController extends GetxController {
  late final CatalogService _catalogService;
  late final CartService _cartService;
  late final AuthController _authController;

  final RxList<Category> categories = <Category>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Variant> variants = <Variant>[].obs;

  final Rx<Cart?> cart = Rx<Cart?>(null);

  final RxString selectedCategorySlug = 'toutes'.obs;
  final RxSet<String> favoriteProductIds = <String>{}.obs;

  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingCart = false.obs;
  final RxBool isMutatingCart = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool hasMore = true.obs;

  bool get isCartBusy => isLoadingCart.value || isMutatingCart.value;

  @override
  void onInit() {
    super.onInit();

    final apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
    _catalogService = CatalogService(apiClient);
    _cartService = CartService(apiClient);
    _authController = Get.find<AuthController>();

    ever(_authController.currentUserRx, (user) {
      if (user == null) {
        _setCart(null);
        return;
      }
      initCart();
    });

    loadCategories();
    loadProducts();

    if (_authController.currentUser != null) {
      initCart();
    }
  }

  void _setCart(Cart? newCart) {
    cart.value = newCart;
    cart.refresh();
  }

  CartItem? _findCartItemByVariant(String variantId) {
    final current = cart.value;
    if (current == null) return null;

    for (final item in current.items) {
      if (item.variant.id == variantId) {
        return item;
      }
    }
    return null;
  }

  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;

      final fetchedCategories = await _catalogService.fetchCategories();

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

  /// Initialise le panier (get_or_create) — utile au login/démarrage.
  Future<void> initCart() async {
    try {
      isLoadingCart.value = true;

      if (_authController.currentUser == null) {
        _setCart(null);
        return;
      }

      final fetchedCart = await _cartService.getOrCreateCart();
      _setCart(fetchedCart);
    } catch (e) {
      debugPrint('Erreur initialisation panier: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger le panier',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCart.value = false;
    }
  }

  /// Recharge silencieuse après mutation. Peut renvoyer null (ex: checkout supprime le panier).
  Future<void> _refreshCart() async {
    if (_authController.currentUser == null) {
      _setCart(null);
      return;
    }

    final fetchedCart = await _cartService.fetchCart();
    _setCart(fetchedCart);
  }

  Future<void> loadCart({bool showLoader = true}) async {
    if (showLoader) {
      await initCart();
      return;
    }

    try {
      await _refreshCart();
    } catch (e) {
      debugPrint('Erreur refresh panier: $e');
    }
  }

  Future<bool> addToCart(Variant variant, {int quantity = 1}) async {
    if (isMutatingCart.value) {
      return false;
    }

    if (_authController.currentUser == null) {
      Get.snackbar(
        'Connexion requise',
        'Connectez-vous pour ajouter un article au panier',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (quantity <= 0) {
      return false;
    }

    try {
      isMutatingCart.value = true;

      if (cart.value == null) {
        await initCart();
      }

      final currentCart = cart.value;
      if (currentCart == null) {
        throw Exception('Impossible de récupérer le panier');
      }

      final existingItem = _findCartItemByVariant(variant.id);

      if (existingItem != null) {
        await _cartService.updateCartItem(
          itemId: existingItem.id,
          quantity: existingItem.quantity + quantity,
          unitPrice: existingItem.unitPrice,
        );
      } else {
        await _cartService.addToCart(
          cartId: currentCart.id,
          variantId: variant.id,
          quantity: quantity,
          unitPrice: variant.finalPrice,
        );
      }

      await _refreshCart();

      Get.snackbar(
        'Succès',
        'Article ajouté au panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutatingCart.value = false;
    }
  }

  Future<bool> removeFromCart(CartItem item) async {
    if (isMutatingCart.value) {
      return false;
    }

    final previousCart = cart.value;

    try {
      isMutatingCart.value = true;

      await _cartService.removeFromCart(item.id);

      try {
        await _refreshCart();
      } catch (e) {
        debugPrint('removeFromCart sync warning: $e');

        // Fallback local si refresh KO, la suppression backend a déjà réussi.
        if (previousCart != null) {
          final updatedItems = List<CartItem>.from(previousCart.items)
            ..removeWhere((cartItem) => cartItem.id == item.id);
          _setCart(previousCart.copyWith(items: updatedItems));
        }
      }

      Get.snackbar(
        'Succès',
        'Article retiré du panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      // Rien n'a été supprimé côté backend, on restaure l'état local précédent.
      if (previousCart != null) {
        _setCart(previousCart);
      }

      Get.snackbar(
        'Erreur',
        'Impossible de retirer l\'article: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutatingCart.value = false;
    }
  }

  Future<bool> updateQuantity(CartItem item, int quantity) async {
    if (isMutatingCart.value) {
      return false;
    }

    if (quantity <= 0) {
      return removeFromCart(item);
    }

    final previousCart = cart.value;

    try {
      isMutatingCart.value = true;

      await _cartService.updateCartItem(
        itemId: item.id,
        quantity: quantity,
        unitPrice: item.unitPrice,
      );

      try {
        await _refreshCart();
      } catch (e) {
        debugPrint('updateQuantity sync warning: $e');

        // Fallback local si refresh KO.
        if (previousCart != null) {
          final updatedItems = List<CartItem>.from(previousCart.items);
          final index = updatedItems.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            updatedItems[index] = updatedItems[index].copyWith(
              quantity: quantity,
            );
            _setCart(previousCart.copyWith(items: updatedItems));
          }
        }
      }

      return true;
    } catch (e) {
      if (previousCart != null) {
        _setCart(previousCart);
      }

      debugPrint('Erreur updateQuantity: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la quantité',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutatingCart.value = false;
    }
  }

  Future<bool> clearCart() async {
    if (isMutatingCart.value) {
      return false;
    }

    final previousCart = cart.value;

    try {
      if (previousCart == null) return true;

      isMutatingCart.value = true;

      await _cartService.clearCart();

      try {
        await _refreshCart();
      } catch (e) {
        debugPrint('clearCart sync warning: $e');
        _setCart(previousCart.copyWith(items: []));
      }

      Get.snackbar(
        'Succès',
        'Panier vidé',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      if (previousCart != null) {
        _setCart(previousCart);
      }

      Get.snackbar(
        'Erreur',
        'Impossible de vider le panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutatingCart.value = false;
    }
  }

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

  int get cartItemsCount => cart.value?.itemsCount ?? 0;

  double get cartTotal => cart.value?.calculatedTotal ?? 0.0;

  String get formattedCartTotal => cart.value?.formattedTotal ?? '0';

  bool get hasItemsInCart => cart.value?.isNotEmpty ?? false;
}
