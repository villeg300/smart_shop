import 'dart:async';

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
  Timer? _cooldownTimer;
  int _remainingSeconds = 0;

  bool get _isCooldownActive => _remainingSeconds > 0;

  String get _cooldownLabel {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startCooldown({int seconds = 60}) {
    _cooldownTimer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _showSuccessPopup({required String email, required Color primaryColor}) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.14),
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Email envoyé',
                style: AppTextStyles.withWeight(
                  AppTextStyles.h3,
                  FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Un email de réinitialisation a été envoyé à',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Fermer'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const ResetPasswordScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text(
                        'Continuer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.requestPasswordReset(
      email: _emailController.text.trim(),
    );

    if (success) {
      if (!mounted) return;
      final primaryColor = Theme.of(context).primaryColor;
      _startCooldown();
      _showSuccessPopup(
        email: _emailController.text.trim(),
        primaryColor: primaryColor,
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

                  const SizedBox(height: 24),

                  // Bouton envoyer
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_authController.isLoading || _isCooldownActive)
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
                                _isCooldownActive
                                    ? "Réactiver dans $_cooldownLabel"
                                    : "Envoyer les codes",
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
