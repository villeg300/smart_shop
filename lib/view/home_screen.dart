import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/theme_controller.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/widgets/category_chips.dart';
import 'package:smart_shop/view/widgets/custom_search_bar.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/product_card.dart';
import 'package:smart_shop/view/widgets/sale_banner.dart';
import 'package:smart_shop/view/cart_screen.dart';
import 'package:smart_shop/view/all_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StoreController storeController = Get.find<StoreController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = AppResponsive.pagePadding(context);
            final spacing = AppResponsive.sectionSpacing(context);
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppResponsive.contentMaxWidth(context),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: padding,
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                    "assets/images/avatar.jpg",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Hello Alex",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "Good Morning",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.notifications_outlined,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Get.to(() => const CartScreen()),
                                      icon: Icon(Icons.shopping_bag_outlined),
                                    ),
                                    GetBuilder<ThemeController>(
                                      builder: (controller) => IconButton(
                                        onPressed: () =>
                                            controller.toggleTheme(),
                                        icon: Icon(
                                          controller.isDarkMode
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: spacing),
                            const CustomSearchBar(),
                            SizedBox(height: spacing),
                            Obx(
                              () => CategoryChips(
                                categories: storeController.categoryLabels,
                                selectedIndex: storeController.indexBySlug(
                                  storeController.selectedCategorySlug.value,
                                ),
                                onSelected: (index) {
                                  storeController
                                      .setCategory(storeController.slugByIndex(index));
                                },
                              ),
                            ),
                            SizedBox(height: spacing),
                            const SaleBanner(),
                            SizedBox(height: spacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Articles Populaires",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Get.to(() => const AllProductsScreen()),
                                  child: Text(
                                    "voir tous",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        padding.left,
                        0,
                        padding.right,
                        padding.bottom,
                      ),
                      sliver: Obx(
                        () => SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product =
                                  storeController.filteredProducts[index];
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
                            childCount:
                                storeController.filteredProducts.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                AppResponsive.gridCrossAxisCount(context),
                            childAspectRatio:
                                AppResponsive.isMobile(context) ? 0.7 : 0.8,
                            crossAxisSpacing:
                                AppResponsive.gridSpacing(context),
                            mainAxisSpacing:
                                AppResponsive.gridSpacing(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
