import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/forgot_password_screen.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';
import 'package:smart_shop/view/main_screen.dart';
import 'package:smart_shop/view/signup_screen.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleSignIn() {
    final AuthController authController = Get.find<AuthController>();
    authController.login();
    Get.off(() => const MainScreen());
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Bienvenue !",
                  style: AppTextStyles.withColor(
                    AppTextStyles.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connectez-vous pour continuer",
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),

                const SizedBox(height: 40),
                CostomTextfield(
                  label: "Telephone",
                  prefixIcon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse e-mail';
                    }
                    if (!GetUtils.isPhoneNumber(value)) {
                      return 'Veuillez entrer une adresse e-mail valide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                CostomTextfield(
                  label: "Mot de passe",
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(ForgotPasswordScreen()),
                    child: Text(
                      "Mot de passe oublié",
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonSmall,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                    ),
                    child: Text(
                      "Se connecter",
                      style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text(
                      "Pas encore de compte ?",
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(SignupScreen()),
                      child: Text(
                        "En créer un",
                        style: AppTextStyles.withColor(
                          AppTextStyles.buttonMedium,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
