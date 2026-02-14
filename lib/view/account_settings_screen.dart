import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/theme_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _marketingEmails = false;
  bool _orderPush = true;

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Parametres')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: ListView(
              padding: padding,
              children: [
                Text(
                  'Personnalisation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: spacing / 2),
                GetBuilder<ThemeController>(
                  builder: (controller) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: controller.isDarkMode,
                    onChanged: (_) => controller.toggleTheme(),
                    title: const Text('Mode sombre'),
                    subtitle: const Text(
                      'Basculer entre le theme clair et sombre',
                    ),
                  ),
                ),
                const Divider(),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: spacing / 2),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _orderPush,
                  onChanged: (value) {
                    setState(() {
                      _orderPush = value;
                    });
                  },
                  title: const Text('Notifications de commande'),
                  subtitle: const Text(
                    'Recevoir les mises a jour de statut de commande',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _marketingEmails,
                  onChanged: (value) {
                    setState(() {
                      _marketingEmails = value;
                    });
                  },
                  title: const Text('Emails promotionnels'),
                  subtitle: const Text(
                    'Recevoir les offres et nouveautes par email',
                  ),
                ),
                const Divider(),
                Text(
                  'Application',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: spacing / 2),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Theme actif'),
                  trailing: Text(
                    themeController.isDarkMode ? 'Sombre' : 'Clair',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
