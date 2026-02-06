import 'package:flutter/material.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = AppResponsive.gridCrossAxisCount(context);
    final spacing = AppResponsive.gridSpacing(context);
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: AppResponsive.isMobile(context) ? 0.7 : 0.8,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          ),
          child: ProductCard(product: product),
        );
      },
    );
  }
}
