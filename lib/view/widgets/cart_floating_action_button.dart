import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/view/cart_screen.dart';

class CartFloatingActionButton extends StatelessWidget {
  final String heroTag;
  final bool showLabel;
  final VoidCallback? onPressed;

  const CartFloatingActionButton({
    super.key,
    required this.heroTag,
    this.showLabel = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final StoreController storeController = Get.find<StoreController>();

    return Obx(() {
      final itemCount = storeController.cartItemsCount;
      final colorScheme = Theme.of(context).colorScheme;
      final callback = onPressed ?? () => Get.to(() => const CartScreen());

      if (showLabel) {
        final label = itemCount > 0 ? 'Panier ($itemCount)' : 'Panier';
        return FloatingActionButton.extended(
          heroTag: heroTag,
          onPressed: callback,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 5,
          highlightElevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: _CartFabIconWithBadge(
            itemCount: itemCount,
            primaryColor: Colors.white,
            onPrimaryColor: Colors.white,
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              key: ValueKey(label),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }

      return FloatingActionButton(
        heroTag: heroTag,
        onPressed: callback,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 5,
        highlightElevation: 7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _CartFabIconWithBadge(
          itemCount: itemCount,
          primaryColor: colorScheme.primary,
          onPrimaryColor: Colors.white,
        ),
      );
    });
  }
}

class _CartFabIconWithBadge extends StatelessWidget {
  final int itemCount;
  final Color primaryColor;
  final Color onPrimaryColor;

  const _CartFabIconWithBadge({
    required this.itemCount,
    required this.primaryColor,
    required this.onPrimaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined),
        if (itemCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: onPrimaryColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
