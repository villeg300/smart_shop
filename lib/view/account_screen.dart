import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/data/mock_data.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    final user = mockUsers.first;
    return Scaffold(
      appBar: AppBar(title: const Text("Compte")),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: Padding(
              padding: padding,
              child: ListView(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage:
                            AssetImage("assets/images/avatar.jpg"),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: AppTextStyles.withWeight(
                                AppTextStyles.h3,
                                FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              user.phone,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Modifier",
                          style: AppTextStyles.withColor(
                            AppTextStyles.buttonMedium,
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  _AccountTile(
                    icon: Icons.location_on_outlined,
                    title: "Adresses de livraison",
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.history,
                    title: "Historique des commandes",
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.payment_outlined,
                    title: "Moyens de paiement",
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.settings_outlined,
                    title: "Parametres",
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.logout,
                    title: "Deconnexion",
                    onTap: () {
                      Get.snackbar(
                        "Deconnexion",
                        "Action de test",
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
