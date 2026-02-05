import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:smart_shop/controllers/theme_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/widgets/category_chips.dart';
import 'package:smart_shop/view/widgets/custom_search_bar.dart';
import 'package:smart_shop/view/widgets/product_grid.dart';
import 'package:smart_shop/view/widgets/sale_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(title: Text("home"))
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
                child: Padding(
                  padding: padding,
                  child: Column(
                    children: [
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
                                icon: Icon(Icons.notifications_outlined),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.shopping_bag_outlined),
                              ),
                              GetBuilder<ThemeController>(
                                builder: (controller) => IconButton(
                                  onPressed: () => controller.toggleTheme(),
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
                      CustomSearchBar(),
                      SizedBox(height: spacing),
                      CategoryChips(),
                      SizedBox(height: spacing),
                      SaleBanner(),
                      SizedBox(height: spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Articles Populaires",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
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
                      const Expanded(child: ProductGrid()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
