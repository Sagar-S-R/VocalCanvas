import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Import dotenv
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'presentation/home/home_screen.dart'; // Import your home screen
import 'presentation/splash/splash_screen.dart';
import 'package:vocal_canvas/presentation/auth/auth_page.dart' as auth;
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
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          displayMedium: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          displaySmall: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          headlineLarge: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          headlineMedium: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          headlineSmall: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          titleLarge: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          titleMedium: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          titleSmall: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          bodyLarge: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
          bodySmall: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
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
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          displayMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          displaySmall: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          headlineLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          headlineMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          headlineSmall: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          titleLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          titleMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          titleSmall: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          bodySmall: TextStyle(color: Colors.white70, fontFamily: 'Roboto'),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(brightness: Brightness.dark),
      ),
      debugShowCheckedModeBanner: false,
      // Start with a splash screen that navigates to Auth
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => auth.AuthPage(),
        '/home': (context) => const VocalCanvasHomePage(),
        '/splash': (context) => const SplashScreen(),
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
          return auth.AuthPage();
        } else {
          return const VocalCanvasHomePage();
        }
      },
    );
  }
}
