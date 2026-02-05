import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/navigation_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();

    return Obx(
      () => BottomNavigationBar(
        currentIndex: navigationController.cureentIndex.value,
        onTap: (index) => navigationController.changeIndex(index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "Shopping",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outlined),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Compte",
          ),
        ],
      ),
    );
  }
}
