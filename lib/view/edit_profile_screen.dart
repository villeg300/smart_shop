import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/auth_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';
import 'package:smart_shop/view/widgets/avatar_upload_field.dart';
import 'package:smart_shop/view/widgets/costom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String? _avatarPath;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _avatarUrl = user?.avatar;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      avatarPath: _avatarPath,
    );

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: _authController.isLoading ? null : _handleSave,
              child: Text(
                'Enregistrer',
                style: TextStyle(
                  color: _authController.isLoading
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
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
                    SizedBox(height: spacing),

                    Center(
                      child: AvatarUploadField(
                        imagePath: _avatarPath,
                        imageUrl: _avatarUrl,
                        label: 'Changer la photo de profil',
                        enabled: !_authController.isLoading,
                        onImageSelected: (path) {
                          setState(() {
                            _avatarPath = path;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: spacing * 2),

                    Text('Informations personnelles', style: AppTextStyles.h3),

                    SizedBox(height: spacing),

                    CostomTextfield(
                      label: 'Nom complet',
                      prefixIcon: Icons.person_outline,
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

                    SizedBox(height: spacing),

                    CostomTextfield(
                      label: 'Email',
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

                    SizedBox(height: spacing),

                    CostomTextfield(
                      label: 'Numéro de téléphone',
                      prefixIcon: Icons.phone_iphone_rounded,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (!value.startsWith('+')) {
                          return 'Le numéro doit commencer par + (ex: +22670123456)';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: spacing * 2),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Les modifications seront appliquées immédiatement',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
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
