import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/cart.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final StoreController controller = Get.find<StoreController>();

  void _changeQuantity(CartItem item, int newQuantity) {
    if (newQuantity < 0) return;

    if (newQuantity == 0) {
      _confirmRemove(item);
    } else {
      controller.updateQuantity(item, newQuantity);
    }
  }

  void _confirmRemove(CartItem item) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'article'),
        content: const Text('Voulez-vous retirer cet article du panier ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeFromCart(item);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
                  // 🔥 CORRECTION 1: Utiliser Obx au lieu de GetBuilder
                  Expanded(
                    child: Obx(() {
                      // Loader
                      if (controller.isLoadingCart.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Panier vide
                      final cart = controller.cart.value;
                      final items = cart?.items ?? [];

                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 100,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Votre panier est vide",
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }

                      // Liste des items
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildVariantImage(
                                    item.variant.image,
                                    size: 80,
                                  ),
                                ),
                                SizedBox(width: spacing),

                                // Infos produit
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (item.variant.sku != null)
                                        Text(
                                          item.variant.sku!,
                                          style: AppTextStyles.withColor(
                                            AppTextStyles.bodySmall,
                                            Colors.grey[600]!,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${item.variant.formattedPrice} FCFA",
                                        style: AppTextStyles.withWeight(
                                          AppTextStyles.bodyMedium,
                                          FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Contrôles quantité
                                Column(
                                  children: [
                                    
                                    IconButton(
                                      onPressed: () {
                                        _changeQuantity(
                                          item,
                                          item.quantity + 1,
                                        );
                                      },
                                      icon: const Icon(Icons.add_circle),
                                      color: Theme.of(context).primaryColor,
                                    ),

                                    // Affichage quantité
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.quantity.toString(),
                                        style: AppTextStyles.withWeight(
                                          AppTextStyles.bodyMedium,
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // 🔥 CORRECTION 3: Bouton - avec icône delete si qty=1
                                    IconButton(
                                      onPressed: () {
                                        _changeQuantity(
                                          item,
                                          item.quantity - 1,
                                        );
                                      },
                                      icon: Icon(
                                        item.quantity == 1
                                            ? Icons.delete
                                            : Icons.remove_circle,
                                      ),
                                      color: item.quantity == 1
                                          ? Colors.red
                                          : Theme.of(context).primaryColor,
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

                  // 🔥 CORRECTION 4: Total avec Obx
                  Obx(() {
                    final cart = controller.cart.value;

                    if (cart == null || cart.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        // Total
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
                              "${controller.formattedCartTotal} FCFA",
                              style: AppTextStyles.withWeight(
                                AppTextStyles.bodyLarge,
                                FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: spacing),

                        // Bouton Commander
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigation vers checkout
                            },
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
                  }),
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
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
