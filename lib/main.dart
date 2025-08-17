import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Import dotenv
import 'presentation/home/home_screen.dart'; // Import your home screen

Future<void> main() async {
  // Ensure Flutter binding is ready before we load env vars
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  runApp(const VocalCanvasApp());
}

class VocalCanvasApp extends StatelessWidget {
  const VocalCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocalCanvas',
      theme: ThemeData.dark().copyWith(
        canvasColor: const Color(0xFFF0EBE3),
      ),
      home: const VocalCanvasHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
