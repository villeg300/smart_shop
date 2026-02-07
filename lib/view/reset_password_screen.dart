import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/signin_screen.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _uidController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.confirmPasswordReset(
      uid: _uidController.text.trim(),
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (success) {
      // Afficher un dialog de succès
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              const Expanded(child: Text('Succès !')),
            ],
          ),
          content: const Text(
            'Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back(); // Fermer le dialog
                Get.offAll(() => const SigninScreen());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Se connecter',
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
                    "Nouveau mot de passe",
                    style: AppTextStyles.withColor(
                      AppTextStyles.h1,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    "Entrez les codes reçus par email et votre nouveau mot de passe.",
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyLarge,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Section Codes
                  Text(
                    "Codes de vérification",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Champ UID
                  CostomTextfield(
                    label: "UID",
                    prefixIcon: Icons.vpn_key_outlined,
                    keyboardType: TextInputType.text,
                    controller: _uidController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le UID';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ TOKEN
                  CostomTextfield(
                    label: "TOKEN",
                    prefixIcon: Icons.key_outlined,
                    keyboardType: TextInputType.text,
                    controller: _tokenController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le TOKEN';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Info box pour les codes
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.mail_outline,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ces codes sont dans l\'email que vous avez reçu. Copiez-les exactement tels qu\'ils apparaissent.',
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

                  const SizedBox(height: 32),

                  // Section Nouveau mot de passe
                  Text(
                    "Nouveau mot de passe",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Champ nouveau mot de passe
                  CostomTextfield(
                    label: "Nouveau mot de passe",
                    prefixIcon: Icons.lock_outline,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 8) {
                        return 'Le mot de passe doit contenir au moins 8 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Champ confirmation
                  CostomTextfield(
                    label: "Confirmer le mot de passe",
                    prefixIcon: Icons.lock_outline,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer le mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Bouton réinitialiser
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : _handleResetPassword,
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
                                "Réinitialiser le mot de passe",
                                style: AppTextStyles.withColor(
                                  AppTextStyles.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Lien retour
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Retour",
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
