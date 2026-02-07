import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/forgot_password_screen.dart';
import 'package:smart_shop/view/main_screen.dart';
import 'package:smart_shop/view/signup_screen.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.login(
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      Get.offAll(() => const MainScreen());
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
                  const SizedBox(height: 40),

                  // Titre
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

                  // Champ téléphone
                  CostomTextfield(
                    label: "Numéro de téléphone",
                    prefixIcon: Icons.phone_iphone_rounded,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      // Format international attendu: +226XXXXXXXX
                      if (!value.startsWith('+')) {
                        return 'Le numéro doit commencer par + (ex: +22670123456)';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ mot de passe
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
                      if (value.length < 8) {
                        return 'Le mot de passe doit contenir au moins 8 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  // Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Get.to(() => const ForgotPasswordScreen()),
                      child: Text(
                        "Mot de passe oublié ?",
                        style: AppTextStyles.withColor(
                          AppTextStyles.buttonSmall,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bouton de connexion
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : _handleSignIn,
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
                                "Se connecter",
                                style: AppTextStyles.withColor(
                                  AppTextStyles.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Lien vers l'inscription
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
                        onPressed: () => Get.to(() => const SignupScreen()),
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
      ),
    );
  }
}
