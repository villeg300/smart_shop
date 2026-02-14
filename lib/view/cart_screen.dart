import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/order_controller.dart';
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
  final StoreController _storeController = Get.find<StoreController>();
  bool _isCheckoutProcessing = false;

  @override
  void initState() {
    super.initState();
    _storeController.loadCart(showLoader: true);
  }

  Future<void> _increment(CartItem item) async {
    await _storeController.updateQuantity(item, item.quantity + 1);
  }

  Future<void> _decrement(CartItem item) async {
    final nextQuantity = item.quantity - 1;
    if (nextQuantity <= 0) {
      _confirmRemove(item);
      return;
    }
    await _storeController.updateQuantity(item, nextQuantity);
  }

  void _confirmRemove(CartItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                size: 32,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Supprimer ${item.variant.product.name}",
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Etes-vous sûr de vouloir supprimer cet item du panier ?",
              textAlign: TextAlign.center,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color,
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await _storeController.removeFromCart(item);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Supprimer',
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Future<void> _checkout() async {
    if (_isCheckoutProcessing || _storeController.isCartBusy) {
      return;
    }

    setState(() {
      _isCheckoutProcessing = true;
    });

    try {
      final orderController = Get.isRegistered<OrderController>()
          ? Get.find<OrderController>()
          : Get.put(OrderController());

      final success = await orderController.placeOrder(
        shippingCost: 0,
        customerNotes: '',
      );

      if (success) {
        await _storeController.loadCart(showLoader: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckoutProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Mon Panier',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
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
                      if (_storeController.isLoadingCart.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final cart = _storeController.cart.value;
                      final items = cart?.items ?? const <CartItem>[];

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
                                'Votre panier est vide',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }

                      final disableActions = _storeController.isCartBusy;

                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: spacing),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return Container(
                            // padding: EdgeInsets.all(spacing),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                  child: _buildVariantImage(
                                    item.variant.image,
                                    size: 100,
                                  ),
                                ),
                                // SizedBox(width: spacing),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.variant.product.name,
                                                style: AppTextStyles.withColor(
                                                  AppTextStyles.bodyLarge,
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge!.color!,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: disableActions
                                                  ? null
                                                  : () => _confirmRemove(item),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red[400],
                                              ),
                                              tooltip: 'Supprimer',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${item.variant.formattedPrice} f',
                                              style: AppTextStyles.withColor(
                                                AppTextStyles.h3,
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.1),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                    vertical: 2,
                                                  ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: disableActions
                                                        ? null
                                                        : () =>
                                                              _decrement(item),
                                                    icon: Icon(
                                                      Icons.remove,
                                                      size: 20,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    item.quantity.toString(),
                                                    style:
                                                        AppTextStyles.withColor(
                                                          AppTextStyles
                                                              .bodyLarge,
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    onPressed: disableActions
                                                        ? null
                                                        : () =>
                                                              _increment(item),
                                                    icon: Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 28,
                                                          minHeight: 28,
                                                        ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                    final cart = _storeController.cart.value;

                    if (cart == null || cart.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final checkoutBusy =
                        _storeController.isCartBusy || _isCheckoutProcessing;

                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total${cart.itemsCount > 1 ? ' (${cart.itemsCount} items)' : ''}',
                                style: AppTextStyles.withColor(
                                  AppTextStyles.bodyLarge,
                                  Theme.of(context).textTheme.bodyLarge!.color!,
                                ),
                              ),
                              Text(
                                '${_storeController.formattedCartTotal} FCFA',
                                style: AppTextStyles.withColor(
                                  AppTextStyles.h2,
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: spacing),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: checkoutBusy ? null : _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                checkoutBusy
                                    ? 'Traitement...'
                                    : 'Passer la commande',
                                style: AppTextStyles.withColor(
                                  AppTextStyles.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
        errorBuilder: (context, error, stackTrace) => Image.asset(
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
