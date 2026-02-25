import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeController = Get.find<StoreController>();
    final padding = AppResponsive.pagePadding(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Favoris")),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: Padding(
              padding: padding,
              child: Obx(() {
                final favorites = storeController.favoriteProducts;

                if (storeController.isLoadingFavorites.value &&
                    favorites.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (favorites.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: storeController.loadFavorites,
                    child: ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            "Aucun favori pour le moment",
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: storeController.loadFavorites,
                  child: GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppResponsive.gridCrossAxisCount(context),
                      childAspectRatio: AppResponsive.isMobile(context)
                          ? 0.7
                          : 0.8,
                      crossAxisSpacing: AppResponsive.gridSpacing(context),
                      mainAxisSpacing: AppResponsive.gridSpacing(context),
                    ),
                    itemBuilder: (context, index) {
                      final product = favorites[index];
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
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
