import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeController = Get.find<StoreController>();
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
              child: Obx(
                () {
                  if (storeController.cartItems.isEmpty) {
                    return Center(
                      child: Text(
                        "Votre panier est vide",
                        style: AppTextStyles.bodyLarge,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: storeController.cartItems.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: spacing),
                          itemBuilder: (context, index) {
                            final item = storeController.cartItems[index];
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
                                    child: Image.asset(
                                      item.variant.image.isNotEmpty
                                          ? item.variant.image
                                          : item.product.image,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: spacing),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: AppTextStyles.withWeight(
                                            AppTextStyles.bodyLarge,
                                            FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.variant.sku,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "f ${item.variant.price.toStringAsFixed(0)}",
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
                                        onPressed: () => storeController
                                            .updateQuantity(
                                          item,
                                          item.quantity.value + 1,
                                        ),
                                        icon: const Icon(Icons.add),
                                      ),
                                      Obx(
                                        () => Text(
                                          item.quantity.value.toString(),
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => storeController
                                            .updateQuantity(
                                          item,
                                          item.quantity.value - 1,
                                        ),
                                        icon: const Icon(Icons.remove),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: spacing),
                      Row(
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
                            "f ${storeController.cartTotal.toStringAsFixed(0)}",
                            style: AppTextStyles.withWeight(
                              AppTextStyles.bodyLarge,
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
