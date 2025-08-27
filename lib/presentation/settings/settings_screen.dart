// SettingsScreen
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ...existing code...

import 'package:provider/provider.dart';
import '../../utils/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header similar to explore page
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                Text(
                  'settings'.tr(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ) ?? const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.info_outline,
                    color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
          // Language Section
          Text(
            "language".tr(),
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text("choose_language".tr()),
              subtitle: Text(
                context.locale.languageCode == 'en'
                    ? 'English'
                    : context.locale.languageCode == 'hi'
                    ? 'हिन्दी'
                    : 'ಕನ್ನಡ',
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
                  onTap: () async {
                    await _handleLogout(context);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 32),

          // Theme Section
          Text(
            "dark_mode".tr(),
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              onChanged: (val) {
                themeProvider.setDarkMode(val);
              },
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
              ListTile(
                title: const Text('ಕನ್ನಡ'),
                leading: Radio<String>(
                  value: 'kn',
                  groupValue: context.locale.languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      context.setLocale(const Locale('kn'));
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  context.setLocale(const Locale('kn'));
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

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Also sign out from Google (if used) to clear web/browser Google session
      try {
        final googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        // On some platforms disconnecting helps fully remove the account grant
        try {
          await googleSignIn.disconnect();
        } catch (_) {}
      } catch (_) {}

      // On web try to reduce persistence so a reload doesn't restore auth silently
      if (kIsWeb) {
        try {
          await FirebaseAuth.instance.setPersistence(Persistence.NONE);
        } catch (_) {}
      }

      // Clear saved language preference (optional)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('languageCode');

      // Navigate to AuthPage and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    } catch (e) {
      // If sign-out failed, show a simple error snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }
}
