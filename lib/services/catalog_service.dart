import 'package:smart_shop/data/mock_data.dart';
import 'package:smart_shop/models/category.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/product_variant.dart';
import 'package:smart_shop/services/api_client.dart';

class CatalogService {
  CatalogService(this._client);

  final ApiClient _client;

  Future<List<Category>> fetchCategories() async {
    // TODO: replace with real API call.
    await Future.delayed(const Duration(milliseconds: 300));
    return mockCategories;
  }

  Future<List<Product>> fetchProducts() async {
    // TODO: replace with real API call.
    await Future.delayed(const Duration(milliseconds: 300));
    return mockCatalog;
  }

  Future<List<ProductVariant>> fetchVariants({String? productSlug}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (productSlug == null) {
      return mockProductVariants;
    }
    return mockProductVariants
        .where((variant) => variant.productSlug == productSlug)
        .toList();
  }
}
