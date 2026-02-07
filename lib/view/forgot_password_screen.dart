import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/reset_password_screen.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.requestPasswordReset(
      email: _emailController.text.trim(),
    );

    if (success) {
      // Afficher un dialog avec les instructions
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Email envoyé')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nous avons envoyé un email de réinitialisation à :',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text.trim(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Vérifiez votre boîte mail\n'
                      '2. Copiez le UID et le TOKEN\n'
                      '3. Revenez ici pour réinitialiser',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Fermer le dialog
                Get.to(() => const ResetPasswordScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppResponsive.authPadding(context),
          child: AppResponsive.authBody(
            context: context,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    "Mot de passe oublié",
                    style: AppTextStyles.withColor(
                      AppTextStyles.h1,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    "Entrez votre adresse e-mail pour recevoir les codes de réinitialisation.",
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyLarge,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Champ email
                  CostomTextfield(
                    label: "E-mail",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre adresse e-mail';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Veuillez entrer une adresse e-mail valide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vous recevrez un email avec un UID et un TOKEN à utiliser pour réinitialiser votre mot de passe.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bouton envoyer
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _authController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "Envoyer les codes",
                                style: AppTextStyles.withColor(
                                  AppTextStyles.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Lien retour connexion
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Retour à la connexion",
                        style: AppTextStyles.withColor(
                          AppTextStyles.buttonMedium,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_shop/utils/app_responsive.dart';
// import 'package:smart_shop/utils/app_textstyles.dart';
// import 'package:smart_shop/view/widgets/costom_textfield.dart';

// class ForgotPasswordScreen extends StatelessWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     void handleReset() {
//       if (emailController.text.isEmpty ||
//           !GetUtils.isEmail(emailController.text)) {
//         Get.snackbar(
//           "Adresse e-mail invalide",
//           "Veuillez entrer une adresse e-mail valide.",
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Theme.of(context).colorScheme.error,
//         );
//         return;
//       }
//       // Get.dialog(
//       //   AlertDialog(
//       //     backgroundColor: Colors.white,
//       //     title: Text("Lien envoyé", style: AppTextStyles.h3),

//       //     content: Text(
//       //       "Vérifiez votre boîte e-mail pour réinitialiser votre mot de passe.",
//       //     ),
//       //     actions: [
//       //       TextButton(
//       //         onPressed: () => Get.back(),
//       //         child: Text(
//       //           "ok",
//       //           style: AppTextStyles.withColor(
//       //             AppTextStyles.buttonMedium,
//       //             Theme.of(context).primaryColor,
//       //           ),
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // );

//       Get.snackbar(
//         "Lien envoyé",
//         "Vérifiez votre boîte e-mail pour réinitialiser votre mot de passe.",
//         // colorText: Colors.white,
//         // backgroundColor: Colors.greenAccent[700],
//         snackPosition: SnackPosition.TOP,
//       );
//     }

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: AppResponsive.authPadding(context),
//           child: AppResponsive.authBody(
//             context: context,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: Icon(
//                     Icons.arrow_back_ios,
//                     color: isDark ? Colors.white : Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   "Mot de passe oublié",
//                   style: AppTextStyles.withColor(
//                     AppTextStyles.h1,
//                     Theme.of(context).textTheme.bodyLarge!.color!,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.",
//                   style: AppTextStyles.withColor(
//                     AppTextStyles.bodyLarge,
//                     isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 CostomTextfield(
//                   label: "E-mail",
//                   prefixIcon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   controller: emailController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Veuillez entrer votre adresse e-mail';
//                     }
//                     if (!GetUtils.isEmail(value)) {
//                       return 'Veuillez entrer une adresse e-mail valide';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: handleReset,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       "Envoyer le lien",
//                       style: AppTextStyles.withColor(
//                         AppTextStyles.buttonMedium,
//                         Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
