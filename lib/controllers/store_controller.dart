import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:smart_shop/models/cart.dart';
import 'package:smart_shop/models/category.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/variant.dart';
import 'package:smart_shop/config/app_config.dart';
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

  final RxInt currentPage = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();

    final apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
    _catalogService = CatalogService(apiClient);
    _cartService = CartService(apiClient);
    _authController = Get.find<AuthController>();

    ever(_authController.currentUserRx, (user) {
      if (user == null) {
        cart.value = null;
        return;
      }
      loadCart();
    });

    loadCategories();
    loadProducts();
    if (_authController.currentUser != null) {
      loadCart();
    }
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

  Future<void> loadCart({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoadingCart.value = true;
      }

      if (_authController.currentUser == null) {
        cart.value = null;
        return;
      }

      final fetchedCart = await _cartService.getOrCreateCart();

      cart.value = fetchedCart;
    } catch (e) {
      debugPrint('Erreur chargement panier: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger le panier',
        snackPosition: SnackPosition.BOTTOM,
      );
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

      final existingItem = cart.value!.items.firstWhereOrNull(
        (item) => item.variant.id == variant.id,
      );

      if (existingItem != null) {
        await _cartService.updateCartItem(
          itemId: existingItem.id,
          cartId: existingItem.cartId,
          variantId: existingItem.variant.id,
          quantity: existingItem.quantity + quantity,
          unitPrice: existingItem.unitPrice,
        );
      } else {
        await _cartService.addToCart(
          cartId: cart.value!.id,
          variantId: variant.id,
          quantity: quantity,
          unitPrice: variant.finalPrice,
        );
      }

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
    final previousCart = cart.value;

    try {
      if (previousCart != null) {
        final updatedItems = List<CartItem>.from(previousCart.items)
          ..removeWhere((cartItem) => cartItem.id == item.id);

        cart.value = previousCart.copyWith(items: updatedItems);
      }

      await _cartService.removeFromCart(item.id);

      Get.snackbar(
        'Succès',
        'Article retiré du panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (previousCart != null) {
        cart.value = previousCart;
      }

      Get.snackbar(
        'Erreur',
        'Impossible de retirer l\'article: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    final previousCart = cart.value;

    try {
      if (previousCart != null) {
        final updatedItems = List<CartItem>.from(previousCart.items);
        final index = updatedItems.indexWhere((i) => i.id == item.id);

        if (index != -1) {
          if (quantity <= 0) {
            updatedItems.removeAt(index);
          } else {
            updatedItems[index] = updatedItems[index].copyWith(
              quantity: quantity,
            );
          }

          cart.value = previousCart.copyWith(items: updatedItems);
        }
      }

      if (quantity <= 0) {
        await _cartService.removeFromCart(item.id);
      } else {
        await _cartService.updateCartItem(
          itemId: item.id,
          cartId: item.cartId,
          variantId: item.variant.id,
          quantity: quantity,
          unitPrice: item.unitPrice,
        );
      }

      await loadCart(showLoader: false);
    } catch (e) {
      if (previousCart != null) {
        cart.value = previousCart;
      }

      debugPrint('Erreur updateQuantity: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la quantité',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearCart() async {
    final previousCart = cart.value;

    try {
      if (previousCart == null) return;

      cart.value = previousCart.copyWith(items: []);

      await _cartService.clearCart(previousCart.id);

      Get.snackbar(
        'Succès',
        'Panier vidé',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (previousCart != null) {
        cart.value = previousCart;
      }

      Get.snackbar(
        'Erreur',
        'Impossible de vider le panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
