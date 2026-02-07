import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/controllers/theme_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/all_products_screen.dart';
import 'package:smart_shop/view/cart_screen.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/category_chips.dart';
import 'package:smart_shop/view/widgets/custom_search_bar.dart';
import 'package:smart_shop/view/widgets/product_card.dart';
import 'package:smart_shop/view/widgets/sale_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StoreController storeController = Get.find<StoreController>();
  final AuthController authController = Get.find<AuthController>();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

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
                        delegate: SliverChildListDelegate([
                          // En-tête avec profil utilisateur
                          Obx(() {
                            final user = authController.currentUser;
                            final userName =
                                user?.fullName.split(' ').first ??
                                'Utilisateur';

                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: user?.avatar != null
                                      ? ClipOval(
                                          child: Image.network(
                                            user!.avatar!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Badge points de fidélité
                                // if (user != null && user.loyaltyPoints > 0)
                                //   Container(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 12,
                                //       vertical: 6,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(
                                //         context,
                                //       ).primaryColor.withOpacity(0.1),
                                //       borderRadius: BorderRadius.circular(20),
                                //     ),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: [
                                //         Icon(
                                //           Icons.star,
                                //           size: 16,
                                //           color: Theme.of(context).primaryColor,
                                //         ),
                                //         const SizedBox(width: 4),
                                //         Text(
                                //           '${user.loyaltyPoints}',
                                //           style: TextStyle(
                                //             color: Theme.of(
                                //               context,
                                //             ).primaryColor,
                                //             fontWeight: FontWeight.bold,
                                //             fontSize: 12,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                const SizedBox(width: 8),
                                Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.notifications_outlined,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Get.to(() => const CartScreen()),
                                      icon: const Icon(
                                        Icons.shopping_bag_outlined,
                                      ),
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
                            );
                          }),
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
                                storeController.setCategory(
                                  storeController.slugByIndex(index),
                                );
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
                        ]),
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
                            childCount: storeController.filteredProducts.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    AppResponsive.gridCrossAxisCount(context),
                                childAspectRatio:
                                    AppResponsive.isMobile(context) ? 0.7 : 0.8,
                                crossAxisSpacing: AppResponsive.gridSpacing(
                                  context,
                                ),
                                mainAxisSpacing: AppResponsive.gridSpacing(
                                  context,
                                ),
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
