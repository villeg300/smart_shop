import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handleReset() {
      if (emailController.text.isEmpty ||
          !GetUtils.isEmail(emailController.text)) {
        Get.snackbar(
          "Adresse e-mail invalide",
          "Veuillez entrer une adresse e-mail valide.",
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }
      // Get.dialog(
      //   AlertDialog(
      //     backgroundColor: Colors.white,
      //     title: Text("Lien envoyé", style: AppTextStyles.h3),

      //     content: Text(
      //       "Vérifiez votre boîte e-mail pour réinitialiser votre mot de passe.",
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Get.back(),
      //         child: Text(
      //           "ok",
      //           style: AppTextStyles.withColor(
      //             AppTextStyles.buttonMedium,
      //             Theme.of(context).primaryColor,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // );

      Get.snackbar(
        "Lien envoyé",
        "Vérifiez votre boîte e-mail pour réinitialiser votre mot de passe.",
        // colorText: Colors.white,
        // backgroundColor: Colors.greenAccent[700],
        snackPosition: SnackPosition.TOP,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppResponsive.authPadding(context),
          child: AppResponsive.authBody(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Mot de passe oublié",
                  style: AppTextStyles.withColor(
                    AppTextStyles.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.",
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),
                CostomTextfield(
                  label: "E-mail",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Envoyer le lien",
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
