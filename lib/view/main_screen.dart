import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/navigation_controller.dart';
import 'package:smart_shop/controllers/theme_controller.dart';
import 'package:smart_shop/view/account_screen.dart';
import 'package:smart_shop/view/home_screen.dart';
import 'package:smart_shop/view/shopping_screen.dart';
import 'package:smart_shop/view/widgets/custom_bottom_nav_bar.dart';
import 'package:smart_shop/view/wishlist_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Obx(
            () => IndexedStack(
              key: ValueKey(navigationController.cureentIndex.value),
              index: navigationController.cureentIndex.value,
              children: [
                HomeScreen(),
                ShoppingScreen(),
                WishlistScreen(),
                AccountScreen(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}
