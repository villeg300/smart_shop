import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeController = Get.find<StoreController>();
    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildProductImage(product.genericImage),
                ),
              ),
              // bouton de favori
              Positioned(
                right: 8,
                top: 8,
                child: Obx(
                  () => IconButton(
                    onPressed: () => storeController.toggleFavorite(product),
                    icon: Icon(
                      storeController.isFavorite(product)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: storeController.isFavorite(product)
                          ? Theme.of(context).primaryColor
                          : isDark
                          ? Colors.grey[400]
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.withColor(
                    AppTextStyles.withWeight(AppTextStyles.h3, FontWeight.bold),
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  product.category.name,
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.minPrice != null
                          ? "${product.minPrice!.toStringAsFixed(0)} fcf"
                          : "Prix indisponible",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.withColor(
                        AppTextStyles.withWeight(
                          AppTextStyles.bodyLarge,
                          FontWeight.bold,
                        ),
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    const placeholder = 'assets/images/laptop.jpg';
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(
        placeholder,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final uri = Uri.tryParse(imagePath);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetwork) {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(placeholder, width: double.infinity, fit: BoxFit.cover),
      );
    }

    return Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover);
  }
}
