import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';

class AccountChangePasswordScreen extends StatefulWidget {
  const AccountChangePasswordScreen({super.key});

  @override
  State<AccountChangePasswordScreen> createState() =>
      _AccountChangePasswordScreenState();
}

class _AccountChangePasswordScreenState
    extends State<AccountChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _authController.changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (!success || !mounted) {
      return;
    }

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Changer le mot de passe')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: SingleChildScrollView(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mise a jour de securite',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: spacing),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _hideCurrent,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe actuel',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideCurrent = !_hideCurrent;
                            });
                          },
                          icon: Icon(
                            _hideCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Entrez votre mot de passe actuel';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: spacing),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _hideNew,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideNew = !_hideNew;
                            });
                          },
                          icon: Icon(
                            _hideNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Entrez le nouveau mot de passe';
                        }
                        if (value.trim().length < 8) {
                          return 'Le mot de passe doit contenir au moins 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: spacing),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le nouveau mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirm = !_hideConfirm;
                            });
                          },
                          icon: Icon(
                            _hideConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Confirmez le nouveau mot de passe';
                        }
                        if (value.trim() != _newPasswordController.text.trim()) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: spacing * 1.5),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        return ElevatedButton(
                          onPressed: _authController.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            _authController.isLoading
                                ? 'Mise a jour...'
                                : 'Mettre a jour',
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
