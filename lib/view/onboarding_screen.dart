import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _curentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      image: 'assets/images/intro.png',
      title: 'Qualité',
      description: 'Decouvrez des telephone et accessoire de qualité',
    ),
    OnboardingItem(
      image: 'assets/images/intro1.png',
      title: 'Reservation',
      description: 'Reservez les articles qui vous interresse en quelque click',
    ),
    OnboardingItem(
      image: 'assets/images/intro2.png',
      title: 'Recuperation',
      description: 'Recuperez vos reservations en toute securité a la boutique',
    ),
  ];

  void _handleGetStarted() {
    final AuthController authController = Get.find<AuthController>();
    authController.setFirstTimeDone();
    Get.off(() => SigninScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _curentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final spacing = AppResponsive.sectionSpacing(context);
              final image = Image.asset(
                _items[index].image,
                height: AppResponsive.isDesktop(context)
                    ? 360
                    : MediaQuery.of(context).size.height * 0.35,
              );
              final textBlock = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: AppResponsive.isDesktop(context)
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text(
                    _items[index].title,
                    textAlign: AppResponsive.isDesktop(context)
                        ? TextAlign.left
                        : TextAlign.center,
                    style: AppTextStyles.withColor(
                      AppTextStyles.h1,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppResponsive.isDesktop(context) ? 420 : 480,
                    ),
                    child: Text(
                      _items[index].description,
                      textAlign: AppResponsive.isDesktop(context)
                          ? TextAlign.left
                          : TextAlign.center,
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyLarge,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  ),
                ],
              );

              return Padding(
                padding: AppResponsive.pagePadding(context),
                child: AppResponsive.isDesktop(context)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Center(child: image)),
                          SizedBox(width: spacing),
                          Expanded(child: textBlock),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          image,
                          SizedBox(height: spacing),
                          textBlock,
                        ],
                      ),
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _curentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _curentPage == index
                        ? Theme.of(context).primaryColor
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _handleGetStarted();
                  },
                  child: Text(
                    "Passer",
                    style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_curentPage < _items.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _handleGetStarted();
                    }
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  child: Text(
                    _curentPage < _items.length - 1 ? "Suivant" : "Commencer",
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;
  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
