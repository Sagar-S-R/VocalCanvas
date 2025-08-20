import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Import dotenv
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'presentation/home/home_screen.dart'; // Import your home screen
import 'presentation/auth/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import 'utils/locale_provider.dart';
import 'utils/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Ensure Flutter binding is ready before we load env vars
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  // Read saved language preference (default to English)
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('languageCode') ?? 'en';
  final startLocale = Locale(savedLang);

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAfE-E1fbW19DMtRKG8TiZu6pfM3u4aptw",
        authDomain: "vocalcanvas-c0c34.firebaseapp.com",
        projectId: "vocalcanvas-c0c34",
        storageBucket: "vocalcanvas-c0c34.firebasestorage.app",
        messagingSenderId: "440043188885",
        appId: "1:440043188885:web:6d0d47d682da2a4a5de19c",
        measurementId: "G-63ZLJZPLPS",
      ),
    );
    // Ensure auth does not persist across page reloads in web builds.
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    } catch (_) {}
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('kn')],
      startLocale: startLocale,
      path: 'assets/lang/',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LocaleProvider(const Locale('en')),
          ),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const VocalCanvasApp(),
      ),
    ),
  );
}

class VocalCanvasApp extends StatelessWidget {
  const VocalCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'VocalCanvas',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        primaryColor: const Color.fromARGB(255, 0, 41, 36),
        scaffoldBackgroundColor: const Color(0xFFF0EBE3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF0EBE3),
          foregroundColor: Color.fromARGB(255, 0, 41, 36),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 0, 41, 36),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 41, 36),
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.black87),
          displayMedium: TextStyle(color: Colors.black87),
          displaySmall: TextStyle(color: Colors.black87),
          headlineLarge: TextStyle(color: Colors.black87),
          headlineMedium: TextStyle(color: Colors.black87),
          headlineSmall: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87),
          titleMedium: TextStyle(color: Colors.black87),
          titleSmall: TextStyle(color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        primaryColor: const Color.fromARGB(255, 0, 41, 36),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 0, 41, 36),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 41, 36),
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(brightness: Brightness.dark),
      ),
      debugShowCheckedModeBanner: false,
      // Use an auth gate as the home so reloads always reflect current auth state
      home: const AuthGate(),
      routes: {
        '/auth': (context) => AuthPage(),
        '/home': (context) => const VocalCanvasHomePage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return AuthPage();
        } else {
          return const VocalCanvasHomePage();
        }
      },
    );
  }
}
