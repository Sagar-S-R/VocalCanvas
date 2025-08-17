import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Import dotenv
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'presentation/home/home_screen.dart'; // Import your home screen

Future<void> main() async {
  // Ensure Flutter binding is ready before we load env vars
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const VocalCanvasApp());
}

class VocalCanvasApp extends StatelessWidget {
  const VocalCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocalCanvas',
      theme: ThemeData.dark().copyWith(canvasColor: const Color(0xFFF0EBE3)),
      home: const VocalCanvasHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
