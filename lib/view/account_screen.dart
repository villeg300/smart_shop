import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/edit_profile_screen.dart';
import 'package:smart_shop/view/signin_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: Padding(
              padding: padding,
              child: Obx(() {
                final user = authController.currentUser;

                // Si pas d'utilisateur, afficher un message
                if (user == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text('Non connecté', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(
                          'Veuillez vous connecter pour accéder à votre compte',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.off(() => const SigninScreen()),
                          child: const Text('Se connecter'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => authController.refreshUserData(),
                  child: ListView(
                    children: [
                      // En-tête profil
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: user.avatar != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.avatar!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Theme.of(context).primaryColor,
                                  ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
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
                                  user.phoneNumber,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Get.to(() => const EditProfileScreen()),
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

                      // Points de fidélité
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Points de fidélité',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${user.loyaltyPoints} points',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacing),

                      // Menu
                      _AccountTile(
                        icon: Icons.location_on_outlined,
                        title: "Adresses de livraison",
                        onTap: () {
                          Get.snackbar(
                            'Bientôt disponible',
                            'Cette fonctionnalité sera disponible prochainement',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      _AccountTile(
                        icon: Icons.history,
                        title: "Historique des commandes",
                        onTap: () {
                          Get.snackbar(
                            'Bientôt disponible',
                            'Cette fonctionnalité sera disponible prochainement',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      _AccountTile(
                        icon: Icons.payment_outlined,
                        title: "Moyens de paiement",
                        onTap: () {
                          Get.snackbar(
                            'Bientôt disponible',
                            'Cette fonctionnalité sera disponible prochainement',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      _AccountTile(
                        icon: Icons.lock_outline,
                        title: "Changer le mot de passe",
                        onTap: () {
                          Get.snackbar(
                            'Bientôt disponible',
                            'Cette fonctionnalité sera disponible prochainement',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      _AccountTile(
                        icon: Icons.settings_outlined,
                        title: "Paramètres",
                        onTap: () {
                          Get.snackbar(
                            'Bientôt disponible',
                            'Cette fonctionnalité sera disponible prochainement',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      const Divider(height: 32),
                      _AccountTile(
                        icon: Icons.logout,
                        title: "Déconnexion",
                        iconColor: Colors.red,
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Déconnexion'),
                              content: const Text(
                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Get.back(); // Fermer le dialog
                                    await authController.logout();
                                    Get.offAll(() => const SigninScreen());
                                  },
                                  child: const Text(
                                    'Déconnexion',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: spacing),
                      // Informations de version
                      Center(
                        child: Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
  final Color? iconColor;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_shop/data/mock_data.dart';
// import 'package:smart_shop/utils/app_responsive.dart';
// import 'package:smart_shop/utils/app_textstyles.dart';

// class AccountScreen extends StatelessWidget {
//   const AccountScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final padding = AppResponsive.pagePadding(context);
//     final spacing = AppResponsive.sectionSpacing(context);
//     final user = mockUsers.first;
//     return Scaffold(
//       appBar: AppBar(title: const Text("Compte")),
//       body: SafeArea(
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: AppResponsive.contentMaxWidth(context),
//             ),
//             child: Padding(
//               padding: padding,
//               child: ListView(
//                 children: [
//                   Row(
//                     children: [
//                       const CircleAvatar(
//                         radius: 32,
//                         backgroundImage: AssetImage("assets/images/avatar.jpg"),
//                       ),
//                       SizedBox(width: spacing),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               user.fullName,
//                               style: AppTextStyles.withWeight(
//                                 AppTextStyles.h3,
//                                 FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(user.email, style: AppTextStyles.bodyMedium),
//                             Text(
//                               user.phoneNumber,
//                               style: AppTextStyles.bodyMedium,
//                             ),
//                           ],
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Modifier",
//                           style: AppTextStyles.withColor(
//                             AppTextStyles.buttonMedium,
//                             Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: spacing),
//                   _AccountTile(
//                     icon: Icons.location_on_outlined,
//                     title: "Adresses de livraison",
//                     onTap: () {},
//                   ),
//                   _AccountTile(
//                     icon: Icons.history,
//                     title: "Historique des commandes",
//                     onTap: () {},
//                   ),
//                   _AccountTile(
//                     icon: Icons.payment_outlined,
//                     title: "Moyens de paiement",
//                     onTap: () {},
//                   ),
//                   _AccountTile(
//                     icon: Icons.settings_outlined,
//                     title: "Parametres",
//                     onTap: () {},
//                   ),
//                   _AccountTile(
//                     icon: Icons.logout,
//                     title: "Deconnexion",
//                     onTap: () {
//                       Get.snackbar(
//                         "Deconnexion",
//                         "Action de test",
//                         snackPosition: SnackPosition.TOP,
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AccountTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;

//   const _AccountTile({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 0),
//       leading: Icon(icon, color: Theme.of(context).primaryColor),
//       title: Text(title, style: AppTextStyles.bodyLarge),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap,
//     );
//   }
// }
