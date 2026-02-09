import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class CartScreen extends GetView<StoreController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Panier")),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: Padding(
              padding: padding,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingCart.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final cart = controller.cart.value;
                      final items = cart?.items ?? [];

                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            "Votre panier est vide",
                            style: AppTextStyles.bodyLarge,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(height: spacing),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            padding: EdgeInsets.all(spacing),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildVariantImage(
                                    item.variant.image,
                                    size: 72,
                                  ),
                                ),
                                SizedBox(width: spacing),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.variant.product.name,
                                        style: AppTextStyles.withWeight(
                                          AppTextStyles.bodyLarge,
                                          FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.variant.sku ?? '',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.variant.formattedPrice,
                                        style: AppTextStyles.withWeight(
                                          AppTextStyles.bodyMedium,
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          controller.updateQuantity(
                                            item,
                                            item.quantity + 1,
                                          ),
                                      icon: const Icon(Icons.add),
                                    ),
                                    Text(
                                      item.quantity.toString(),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          controller.updateQuantity(
                                            item,
                                            item.quantity - 1,
                                          ),
                                      icon: const Icon(Icons.remove),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  SizedBox(height: spacing),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: AppTextStyles.withWeight(
                            AppTextStyles.bodyLarge,
                            FontWeight.w600,
                          ),
                        ),
                        Text(
                          "f ${controller.formattedCartTotal}",
                          style: AppTextStyles.withWeight(
                            AppTextStyles.bodyLarge,
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: spacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Passer la commande",
                        style: AppTextStyles.withColor(
                          AppTextStyles.buttonMedium,
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariantImage(String? imagePath, {required double size}) {
    const placeholder = 'assets/images/laptop.jpg';
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(
        placeholder,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    final uri = Uri.tryParse(imagePath);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetwork) {
      return Image.network(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Image.asset(
          placeholder,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(imagePath, width: size, height: size, fit: BoxFit.cover);
  }
}
