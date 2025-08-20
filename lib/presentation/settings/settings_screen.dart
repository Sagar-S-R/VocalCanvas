// SettingsScreen
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatelessWidget {
  final Function(bool)? onThemeToggle;

  const SettingsScreen({super.key, this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("settings".tr()),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Language Section
          Text(
            "language".tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text("choose_language".tr()),
              subtitle: Text(
                context.locale.languageCode == 'en' ? 'English' : 'हिन्दी',
              ),
              onTap: () => _showLanguageDialog(context),
            ),
          ),
          const Divider(height: 32),

          // Account Section
          const Text(
            'Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('edit_profile'.tr()),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 32),

          // Theme Section
          Text(
            "dark_mode".tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: SwitchListTile(
              title: Text("dark_mode".tr()),
              subtitle: Text(
                isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
              ),
              value: isDarkMode,
              onChanged: onThemeToggle,
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
          const Divider(height: 32),

          // App Info Section
          const Text(
            'App Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About VocalCanvas'),
              subtitle: const Text('Version 1.0.0'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("choose_language".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: context.locale.languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      context.setLocale(const Locale('en'));
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('हिन्दी'),
                leading: Radio<String>(
                  value: 'hi',
                  groupValue: context.locale.languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      context.setLocale(const Locale('hi'));
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  context.setLocale(const Locale('hi'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel".tr()),
            ),
          ],
        );
      },
    );
  }
}
