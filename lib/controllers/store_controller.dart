import 'package:get/get.dart';
import 'package:smart_shop/data/mock_data.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/product_variant.dart';

class CartItem {
  final Product product;
  final ProductVariant variant;
  final RxInt quantity;

  CartItem({
    required this.product,
    required this.variant,
    int quantity = 1,
  }) : quantity = quantity.obs;

  double get lineTotal => variant.price * quantity.value;
}

class StoreController extends GetxController {
  final RxString selectedCategorySlug = 'toutes'.obs;
  final RxSet<String> favoriteSlugs = <String>{}.obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  List<Product> get products => mockCatalog;

  List<String> get categoryLabels =>
      mockCategories.map((category) => category.name).toList();

  String slugByIndex(int index) {
    if (index < 0 || index >= mockCategories.length) {
      return 'toutes';
    }
    return mockCategories[index].slug;
  }

  int indexBySlug(String slug) {
    final index =
        mockCategories.indexWhere((category) => category.slug == slug);
    return index == -1 ? 0 : index;
  }

  List<Product> get filteredProducts {
    if (selectedCategorySlug.value == 'toutes') {
      return mockCatalog;
    }
    return mockCatalog
        .where((product) => product.category.slug == selectedCategorySlug.value)
        .toList();
  }

  void setCategory(String slug) {
    selectedCategorySlug.value = slug;
  }

  bool isFavorite(Product product) {
    return favoriteSlugs.contains(product.slug);
  }

  void toggleFavorite(Product product) {
    if (favoriteSlugs.contains(product.slug)) {
      favoriteSlugs.remove(product.slug);
    } else {
      favoriteSlugs.add(product.slug);
    }
  }

  void addToCart(Product product, ProductVariant variant) {
    CartItem? existing;
    for (final item in cartItems) {
      if (item.product.slug == product.slug &&
          item.variant.sku == variant.sku) {
        existing = item;
        break;
      }
    }
    if (existing != null) {
      existing.quantity.value += 1;
    } else {
      cartItems.add(CartItem(product: product, variant: variant));
    }
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      cartItems.remove(item);
      return;
    }
    item.quantity.value = quantity;
  }

  double get cartTotal {
    return cartItems.fold(0, (total, item) => total + item.lineTotal);
  }
}
