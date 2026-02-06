import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/product_variant.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedVariantIndex = 0;
  final StoreController storeController = Get.find<StoreController>();

  Product get product => widget.product;

  ProductVariant? get selectedVariant {
    if (product.variants.isEmpty) {
      return null;
    }
    final index = selectedVariantIndex.clamp(0, product.variants.length - 1);
    return product.variants[index];
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppResponsive.screenHeight(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variant = selectedVariant;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _shareProduct(context, product.name, product.description),
            icon: Icon(
              Icons.share,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Obx(
            () => IconButton(
              onPressed: () => storeController.toggleFavorite(product),
              icon: Icon(
                storeController.isFavorite(product)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: storeController.isFavorite(product)
                    ? Theme.of(context).primaryColor
                    : isDark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ],
        title: Text(
          'Details',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = AppResponsive.isDesktop(context);
          final padding = AppResponsive.pagePadding(context);
          final spacing = AppResponsive.sectionSpacing(context);
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppTextStyles.withColor(
                  AppTextStyles.h2,
                  Theme.of(context).textTheme.headlineMedium!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.category.name,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              SizedBox(height: spacing),
              Text(
                variant == null
                    ? "Prix indisponible"
                    : "f ${variant.price.toStringAsFixed(0)}",
                style: AppTextStyles.withColor(
                  AppTextStyles.withWeight(
                    AppTextStyles.bodyLarge,
                    FontWeight.bold,
                  ),
                  Theme.of(context).textTheme.headlineMedium!.color!,
                ),
              ),
              if (variant?.compareAtPrice != null) ...[
                const SizedBox(height: 6),
                Text(
                  "f ${variant!.compareAtPrice!.toStringAsFixed(0)}",
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodySmall,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
              ],
              SizedBox(height: spacing),
              if (product.variants.isNotEmpty) ...[
                Text(
                  "Selectionner une variante",
                  style: AppTextStyles.withColor(
                    AppTextStyles.labelMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                SizedBox(height: spacing / 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(product.variants.length, (index) {
                    final item = product.variants[index];
                    final label = _variantLabel(item);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selectedVariantIndex == index,
                      onSelected: (selected) {
                        if (!selected) {
                          return;
                        }
                        setState(() {
                          selectedVariantIndex = index;
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: selectedVariantIndex == index
                            ? Colors.white
                            : isDark
                            ? Colors.grey[300]
                            : Colors.grey[800],
                      ),
                    );
                  }),
                ),
              ],
              SizedBox(height: spacing),
              Text(
                "Description",
                style: AppTextStyles.withColor(
                  AppTextStyles.labelMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              SizedBox(height: spacing / 2),
              Text(
                product.description,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodySmall,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          );

          final imagePath = (variant?.image.isNotEmpty ?? false)
              ? variant!.image
              : product.image;

          final imageWidget = Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Positioned(
              //   right: 8,
              //   top: 8,
              //   child: IconButton(
              //     onPressed: () {},
              //     icon: Icon(
              //       Icons.favorite_border,
              //       color: isDark ? Colors.black : Colors.white,
              //     ),
              //   ),
              // ),
            ],
          );

          return SingleChildScrollView(
            padding: padding,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppResponsive.contentMaxWidth(context),
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: imageWidget),
                          SizedBox(width: spacing),
                          Expanded(child: content),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imageWidget,
                          SizedBox(height: spacing),
                          content,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.pagePadding(context).horizontal / 2,
            vertical: AppResponsive.isMobile(context) ? 12 : 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: variant == null
                      ? null
                      : () => storeController.addToCart(product, variant),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white70 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    "Ajouter Au Panier",
                    style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.itemSpacing(context)),
              Expanded(
                child: ElevatedButton(
                  onPressed: variant == null
                      ? null
                      : () => storeController.addToCart(product, variant),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    "Reserver",
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
    );
  }

  Future<void> _shareProduct(
    BuildContext context,
    String productName,
    String description,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    String shopLink = "https://smarShop.com/product/${productName}";
    final String shareMessage =
        "$description\n\nAcheter maintenant a $shopLink";

    try {
      final ShareResult result = await Share.share(
        shareMessage,
        subject: productName,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      if (result.status == ShareResultStatus.success) {
        debugPrint("Meci pour le partage");
      }
    } catch (e) {
      debugPrint("Erreur de partage: $e");
    }
  }

  String _variantLabel(ProductVariant variant) {
    final parts = <String>[];
    if (variant.attributes['color'] != null) {
      parts.add(variant.attributes['color'].toString());
    }
    if (variant.attributes['storage'] != null) {
      parts.add(variant.attributes['storage'].toString());
    }
    if (parts.isEmpty) {
      return variant.sku;
    }
    return parts.join(' · ');
  }
}
