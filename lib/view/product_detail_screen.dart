import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/models/variant.dart';
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
  final List<Variant> variants = [];
  bool isLoadingVariants = false;

  Product get product => widget.product;

  Variant? get selectedVariant {
    if (variants.isEmpty) {
      return null;
    }
    final index = selectedVariantIndex.clamp(0, variants.length - 1);
    return variants[index];
  }

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  Future<void> _loadVariants() async {
    setState(() {
      isLoadingVariants = true;
    });

    final fetched = await storeController.loadVariantsForProduct(product.id);
    if (!mounted) return;

    setState(() {
      variants
        ..clear()
        ..addAll(fetched);
      selectedVariantIndex = 0;
      isLoadingVariants = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppResponsive.screenHeight(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variant = selectedVariant;
    final variantDescription =
        (variant?.description?.trim().isNotEmpty ?? false)
        ? variant!.description!.trim()
        : null;
    final descriptionText = variantDescription ?? product.description;
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
              const SizedBox(height: 6),
              Text(
                product.category.name,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              SizedBox(height: spacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      variant == null
                          ? _withCurrency(product.priceRange)
                          : _withCurrency(variant.formattedPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.withColor(
                        AppTextStyles.withWeight(
                          AppTextStyles.bodyLarge,
                          FontWeight.bold,
                        ),
                        Theme.of(context).textTheme.headlineMedium!.color!,
                      ),
                    ),
                  ),
                  if (variant?.formattedOldPrice != null &&
                      variant!.formattedOldPrice!.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      _withCurrency(variant.formattedOldPrice!),
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodySmall,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              SizedBox(height: spacing),
              if (variant != null && variant.attributesMap.isNotEmpty) ...[
                SizedBox(height: spacing),
                Text(
                  "Caracteristiques",
                  style: AppTextStyles.withColor(
                    AppTextStyles.labelMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                SizedBox(height: spacing / 2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: variant.attributesMap.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${entry.key}: ${entry.value}",
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodySmall,
                            isDark ? Colors.grey[200]! : Colors.grey[800]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              SizedBox(height: spacing),
              if (isLoadingVariants)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (variants.isNotEmpty) ...[
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
                  children: List.generate(variants.length, (index) {
                    final item = variants[index];
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
                descriptionText,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodySmall,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          );

          final imagePath = (variant?.image?.isNotEmpty ?? false)
              ? variant!.image
              : product.genericImage;

          final imageWidget = Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: _buildProductImage(imagePath),
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
                      : () => storeController.addToCart(variant),
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
                      : () => storeController.addToCart(variant),
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

  String _variantLabel(Variant variant) {
    if (variant.attributesDisplay.isNotEmpty) {
      return variant.attributesDisplay;
    }
    final parts = variant.attributesMap.values.toList();
    if (parts.isEmpty) {
      return variant.sku ?? variant.id;
    }
    return parts.join(' · ');
  }

  String _withCurrency(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    final hasCurrency = RegExp(
      r'(fcfa|fcf|xaf)',
      caseSensitive: false,
    ).hasMatch(trimmed);
    if (hasCurrency || !RegExp(r'\d').hasMatch(trimmed)) {
      return trimmed;
    }
    return "$trimmed FCFA";
  }
}
