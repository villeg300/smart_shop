import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/main_screen.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.register(
      phoneNumber: _phoneController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
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
      appBar: AppBar(title: const Text("Créer un compte"), centerTitle: true),
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
                  const SizedBox(height: 20),

                  Text(
                    "Rejoignez-nous !",
                    style: AppTextStyles.withColor(
                      AppTextStyles.h1,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Créez votre compte pour commencer",
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyLarge,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Nom complet
                  CostomTextfield(
                    label: "Nom complet",
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom complet';
                      }
                      if (value.length < 3) {
                        return 'Le nom doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Téléphone
                  CostomTextfield(
                    label: "Numéro de téléphone",
                    prefixIcon: Icons.phone_iphone_rounded,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      if (!value.startsWith('+')) {
                        return 'Le numéro doit commencer par + (ex: +22670123456)';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email
                  CostomTextfield(
                    label: "Email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Mot de passe
                  CostomTextfield(
                    label: "Mot de passe",
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

                  // Confirmation mot de passe
                  CostomTextfield(
                    label: "Confirmer le mot de passe",
                    prefixIcon: Icons.lock_outline,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Bouton d'inscription
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : _handleSignUp,
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
                                "Créer mon compte",
                                style: AppTextStyles.withColor(
                                  AppTextStyles.buttonMedium,
                                  Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Lien vers la connexion
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Text(
                        "Vous avez déjà un compte ?",
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyMedium,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Se connecter",
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'package:smart_shop/controllers/auth_controller.dart';
// import 'package:smart_shop/utils/app_responsive.dart';
// import 'package:smart_shop/utils/app_textstyles.dart';
// import 'package:smart_shop/view/widgets/costom_textfield.dart';
// import 'package:smart_shop/view/main_screen.dart';
// import 'package:smart_shop/view/signin_screen.dart';

// class SignupScreen extends StatelessWidget {
//   SignupScreen({super.key});
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   void _handleSignUp() {
//     // final AuthController authController = Get.find<AuthController>();
//     // authController.login();
//     Get.off(() => const MainScreen());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

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
//                   "Créer un compte",
//                   style: AppTextStyles.withColor(
//                     AppTextStyles.h1,
//                     Theme.of(context).textTheme.bodyLarge!.color!,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Créez un compte pour commencer",
//                   style: AppTextStyles.withColor(
//                     AppTextStyles.bodyLarge,
//                     isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 CostomTextfield(
//                   label: "Nom et prénom",
//                   prefixIcon: Icons.person_outline,
//                   keyboardType: TextInputType.name,
//                   controller: _nameController,
//                   validator: (value) {
//                     if ((value == null || value.isEmpty) ||
//                         (!GetUtils.isAlphabetOnly(value))) {
//                       return 'Veuillez entrer votre nom et prénom';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 CostomTextfield(
//                   label: "Telephone",
//                   prefixIcon: Icons.phone_iphone_rounded,
//                   keyboardType: TextInputType.phone,
//                   controller: _phoneController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Veuillez entrer votre adresse e-mail';
//                     }
//                     if (!GetUtils.isPhoneNumber(value)) {
//                       return 'Veuillez entrer une adresse e-mail valide';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 CostomTextfield(
//                   label: "E-mail",
//                   prefixIcon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   controller: _emailController,
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
//                 const SizedBox(height: 16),
//                 CostomTextfield(
//                   label: "Mot de passe",
//                   prefixIcon: Icons.lock_outline,
//                   keyboardType: TextInputType.visiblePassword,
//                   isPassword: true,
//                   controller: _passwordController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Veuillez entrer un mot de passe';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 CostomTextfield(
//                   label: "Confirmez le mot de passe",
//                   prefixIcon: Icons.lock_outline,
//                   keyboardType: TextInputType.visiblePassword,
//                   isPassword: true,
//                   controller: _confirmPasswordController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Veuillez confirmer votre mot de passe';
//                     }
//                     if (value != _confirmPasswordController.text) {
//                       return 'Le mot de passe ne correspond pas';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _handleSignUp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       "Créer un compte",
//                       style: AppTextStyles.withColor(
//                         AppTextStyles.buttonMedium,
//                         Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Wrap(
//                   alignment: WrapAlignment.center,
//                   crossAxisAlignment: WrapCrossAlignment.center,

//                   spacing: 6,
//                   runSpacing: 6,
//                   children: [
//                     Text(
//                       "Déjà inscrit ?",
//                       style: AppTextStyles.withColor(
//                         AppTextStyles.bodyMedium,
//                         isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => Get.to(SigninScreen()),
//                       child: Text(
//                         "Se connecter",
//                         style: AppTextStyles.withColor(
//                           AppTextStyles.buttonMedium,
//                           Theme.of(context).primaryColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
