import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../presentation/auth/auth_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  Future<void> _setLanguage(BuildContext context, Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    context.setLocale(locale);
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("choose_language".tr(), style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _setLanguage(context, Locale('en')),
              child: const Text("English"),
            ),
            ElevatedButton(
              onPressed: () => _setLanguage(context, Locale('hi')),
              child: const Text("हिंदी"),
            ),
            ElevatedButton(
              onPressed: () => _setLanguage(context, Locale('kn')),
              child: const Text("ಕನ್ನಡ"),
            ),
          ],
        ),
      ),
    );
  }
}
