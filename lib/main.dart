import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Import dotenv
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'presentation/home/home_screen.dart'; // Import your home screen
import 'presentation/auth/auth_page.dart';

import 'package:provider/provider.dart';
import 'utils/locale_provider.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  // Ensure Flutter binding is ready before we load env vars
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

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
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/lang/',
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => LocaleProvider(const Locale('en')),
        child: const VocalCanvasApp(),
      ),
    ),
  );
}

class VocalCanvasApp extends StatefulWidget {
  const VocalCanvasApp({super.key});

  @override
  State<VocalCanvasApp> createState() => _VocalCanvasAppState();
}

class _VocalCanvasAppState extends State<VocalCanvasApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocalCanvas',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: _themeMode,
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
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthPage(onThemeToggle: _toggleTheme),
        '/home': (context) => const VocalCanvasHomePage(),
      },
    );
  }
}
