import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/controllers/navigation_controller.dart';
import 'package:smart_shop/controllers/theme_controller.dart';
import 'package:smart_shop/utils/app_themes.dart';
import 'package:smart_shop/view/splash_screen.dart';

void main() async {
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Shop',
      theme: AppThemes.light,
      // theme: AppThemes.dark,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,

      home: SplashScreen(),
    );
  }
}
