import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/category_chips.dart';
import 'package:smart_shop/view/widgets/custom_search_bar.dart';
import 'package:smart_shop/view/widgets/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

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
                      delegate: SliverChildListDelegate(
                        [
                          const CustomSearchBar(),
                          SizedBox(height: spacing),
                          const CategoryChips(),
                          SizedBox(height: spacing),
                        ],
                      ),
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

                      if (storeController.filteredProducts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text("Aucun produit disponible"),
                            ),
                          ),
                        );
                      }

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product =
                                storeController.filteredProducts[index];
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
                          },
                          childCount: storeController.filteredProducts.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              AppResponsive.gridCrossAxisCount(context),
                          childAspectRatio:
                              AppResponsive.isMobile(context) ? 0.7 : 0.8,
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
