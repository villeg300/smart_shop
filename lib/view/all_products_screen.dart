import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/category_chips.dart';
import 'package:smart_shop/view/widgets/product_card.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      final name = product.name.toLowerCase();
      final brand = product.brand.toLowerCase();
      final model = product.model.toLowerCase();
      final category = product.category.name.toLowerCase();
      return name.contains(query) ||
          brand.contains(query) ||
          model.contains(query) ||
          category.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final storeController = Get.find<StoreController>();
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Tous les produits")),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  storeController.loadMoreProducts();
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: padding,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: (value) {
                            setState(() {
                              _query = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Rechercher un produit...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.trim().isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _query = '';
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        const CategoryChips(),
                        SizedBox(height: spacing),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      padding.left,
                      0,
                      padding.right,
                      padding.bottom,
                    ),
                    sliver: Obx(() {
                      final visibleProducts = _filterProducts(
                        storeController.filteredProducts,
                      );

                      if (storeController.isLoadingProducts.value &&
                          storeController.filteredProducts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      if (visibleProducts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text("Aucun produit ne correspond"),
                            ),
                          ),
                        );
                      }

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = visibleProducts[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            ),
                            child: ProductCard(product: product),
                          );
                        }, childCount: visibleProducts.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: AppResponsive.gridCrossAxisCount(
                            context,
                          ),
                          childAspectRatio: AppResponsive.isMobile(context)
                              ? 0.7
                              : 0.8,
                          crossAxisSpacing: AppResponsive.gridSpacing(context),
                          mainAxisSpacing: AppResponsive.gridSpacing(context),
                        ),
                      );
                    }),
                  ),
                  Obx(() {
                    if (storeController.isLoadingProducts.value &&
                        storeController.filteredProducts.isNotEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
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
